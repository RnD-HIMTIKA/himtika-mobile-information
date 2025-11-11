import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text; // 'hide Text' untuk menghindari konflik
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart'; // Untuk embed (gambar, dll)
import 'package:himtika_mobile_information/features/AdminPanel/data/models/hicode_chapter_model.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/hicode_chapter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/chapter_management/chapter_management_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/upload_hicode_image.dart';

class ModifyChapterDialog extends StatefulWidget {
  final String materialId;
  final HiCodeChapter? chapterToEdit;

  const ModifyChapterDialog({
    super.key,
    required this.materialId,
    this.chapterToEdit,
  });

  @override
  State<ModifyChapterDialog> createState() => _ModifyChapterDialogState();
}

class _ModifyChapterDialogState extends State<ModifyChapterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _readTimeController = TextEditingController();

  QuillController? _quillController;
  bool _isLoadingContent = true;
  bool _isUploadingImage = false;
  bool _isQuizless = false;

  // Definisikan ScrollController dan FocusNode di state (Good practice)
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool get isEditing => widget.chapterToEdit != null;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeEditor(); // Panggilan ini sudah ada

    // Tambahkan ini
    if (isEditing) {
      _titleController.text = widget.chapterToEdit!.title;
      _readTimeController.text =
          widget.chapterToEdit!.estimatedReadTime?.toString() ?? '';

      // (Kita perlu update entity & model dulu agar ini berhasil)
      _isQuizless = widget.chapterToEdit!.isQuizless; 
    }
  }

  void _initializeEditor() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      dynamic initialContentData;
      if (isEditing && widget.chapterToEdit?.content != null) {
        initialContentData = widget.chapterToEdit!.content;
        _titleController.text = widget.chapterToEdit!.title;
        _readTimeController.text =
            widget.chapterToEdit!.estimatedReadTime?.toString() ?? '';
      }

      try {
        Document doc;
        if (initialContentData != null &&
            initialContentData is List &&
            initialContentData.isNotEmpty) {
          doc = Document.fromJson(List<dynamic>.from(initialContentData));
        } else {
          doc = Document(); // Editor kosong
        }

        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: false,
        );
      } catch (e) {
        print("Error initializing Quill controller: $e");
        _quillController = QuillController.basic();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Gagal memuat konten chapter, editor dimulai kosong.'),
            backgroundColor: Colors.orange,
          ));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingContent = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _readTimeController.dispose();
    _quillController?.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- Kompresi Gambar (Tidak Berubah) ---
  Future<File?> compressImage(XFile imageFile) async {
    final filePath = imageFile.path;
    final fileName = p.basename(filePath);
    final lastIndex = fileName.lastIndexOf('.');
    String name = fileName;
    String extension = '';
    if (lastIndex != -1) {
      name = fileName.substring(0, lastIndex);
      extension = fileName.substring(lastIndex);
    }

    final dir = Directory.systemTemp;
    final outPath = "${dir.path}/${name}_compressed$extension";

    Uint8List? result = await FlutterImageCompress.compressWithFile(
      filePath,
      minWidth: 1080,
      quality: 75,
      format: extension.toLowerCase().contains('png')
          ? CompressFormat.png
          : CompressFormat.jpeg,
    );

    if (result != null) {
      final file = File(outPath)..writeAsBytesSync(result);
      return file;
    }
    return null;
  }

  // --- Upload & Insert Gambar Manual ---
  Future<void> _insertImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // --- VALIDASI UKURAN FILE (POIN 5) ---
    final fileSize = await pickedFile.length();
    const maxSizeInBytes = 5 * 1024 * 1024; // 5 MB
    if (fileSize > maxSizeInBytes) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal: Ukuran gambar melebihi 5 MB.'), backgroundColor: Colors.red),
          );
       }
       return;
    }
    // --- AKHIR VALIDASI ---

    setState(() => _isUploadingImage = true);

    try {
      final compressed = await compressImage(pickedFile);
      final fileToUpload = compressed ?? File(pickedFile.path);

      final uploadUseCase = sl<UploadHicodeImage>();
      // PERHATIAN: Pastikan RLS Anda mengizinkan upload ke folder 'materi_konten'
      // atau ganti 'materi_konten' ke 'soal' jika itu yang diizinkan.
      final imageUrl = await uploadUseCase(fileToUpload, 'materi_konten'); 

      final index = _quillController!.selection.baseOffset;
      final length = _quillController!.selection.extentOffset - index;

      // PERBAIKAN v11:
      // 1. Gunakan 'BlockEmbed.image'
      // 2. Gunakan 'document.replace'
      _quillController!.document.replace(
        index,
        length,
        BlockEmbed.image(imageUrl), // <-- Ini sudah benar di kode Anda
      );

      // Pindahkan kursor ke setelah gambar
      _quillController!.updateSelection(
        TextSelection.collapsed(offset: index + 1),
        ChangeSource.local,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gambar berhasil ditambahkan!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // --- Fungsi Baru: Insert Video (Mirip Gambar, dengan Validasi Ukuran) ---
  Future<void> _insertVideo() async {
    final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo == null) return;

    // --- VALIDASI UKURAN FILE (Contoh Max 50 MB untuk Video) ---
    final fileSize = await pickedVideo.length();
    const maxSizeInBytes = 50 * 1024 * 1024; // 50 MB
    if (fileSize > maxSizeInBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal: Ukuran video melebihi 50 MB.'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    // --- AKHIR VALIDASI ---

    setState(() => _isUploadingImage = true); // Reuse indicator untuk video

    try {
      final fileToUpload = File(pickedVideo.path);
      final uploadUseCase = sl<UploadHicodeImage>(); // Asumsi usecase dukung video; jika tidak, buat usecase baru untuk media
      final videoUrl = await uploadUseCase(fileToUpload, 'materi_konten');

      final index = _quillController!.selection.baseOffset;
      final length = _quillController!.selection.extentOffset - index;

      _quillController!.document.replace(
        index,
        length,
        BlockEmbed.video(videoUrl),
      );

      _quillController!.updateSelection(
        TextSelection.collapsed(offset: index + 1),
        ChangeSource.local,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Video berhasil ditambahkan!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload video: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _onSavePressed() {
    if (_quillController == null || _isLoadingContent) return;

    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final readTime = int.tryParse(_readTimeController.text.trim());
      
      // Simpan sebagai List<dynamic> (Delta JSON)
      final contentJson = _quillController!.document.toDelta().toJson();

      if (contentJson.isEmpty ||
          (contentJson.length == 1 && contentJson[0]['insert'] == '\n')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Konten chapter tidak boleh kosong.'),
          backgroundColor: Colors.orange,
        ));
        return;
      }

      final bloc = context.read<ChapterManagementBloc>();
      // Logika BLoC Anda sudah benar
      if (isEditing) {
        bloc.add(UpdateChapterSubmitted(
          id: widget.chapterToEdit!.id,
          title: title,
          content: contentJson, // Kirim List
          estimatedReadTime: readTime,
          isQuizless: _isQuizless,
        ));
      } else {
        bloc.add(AddChapterSubmitted(
          materialId: widget.materialId,
          title: title,
          content: contentJson, // Kirim List
          estimatedReadTime: readTime,
          isQuizless: _isQuizless,
        ));
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingContent || _quillController == null) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Memuat Editor..."),
            ],
          ),
        ),
      );
    }

    // Pastikan _quillController sudah diinisialisasi
    final quillController = _quillController;
    if (quillController == null) {
       return const Dialog(child: Center(child: Text("Controller gagal dimuat.")));
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      title: Text(isEditing ? 'Edit Chapter' : 'Tambah Chapter Baru'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.65,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Chapter',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Chapter Hanya-Baca (Tanpa Kuis)"),
                value: _isQuizless,
                onChanged: (val) => setState(() => _isQuizless = val),
                dense: true,
                contentPadding: EdgeInsets.zero,
                subtitle: const Text("Jika aktif, chapter ini akan selesai setelah di-scroll."),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _readTimeController,
                decoration: const InputDecoration(
                  labelText: 'Estimasi Waktu Baca (Menit)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // --- PERBAIKAN TOTAL TOOLBAR v11 ---
              // Inside the build method, under the Form Column
              QuillSimpleToolbar(
              controller: quillController,
              config: QuillSimpleToolbarConfig(
                multiRowsDisplay: false,
                customButtons: [
                  // Custom button for image insertion with your logic
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.image, size: 20),
                    onPressed: _insertImage,
                  ),
                  // Custom button for video insertion with your logic
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.videocam, size: 20),
                    onPressed: _insertVideo,
                  ),
                ],
                showAlignmentButtons: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showCodeBlock: true,
                showQuote: true,
                showInlineCode: true,
                showHeaderStyle: true,
                showListBullets: true,
                showListNumbers: true,
                showListCheck: true,
              ),
            ),
              const SizedBox(height: 8),

              // --- PERBAIKAN TOTAL EDITOR v11 ---
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QuillEditor.basic(
                    controller: quillController,
                    config: QuillEditorConfig(
                      padding: const EdgeInsets.all(8),
                      embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(), // Sudah dukung video render dari contoh
                    ),
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                  ),
                ),
              ),

              // --- Loading Upload (Tidak Berubah) ---
              if (_isUploadingImage)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text("Mengunggah gambar...",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal')),
        ElevatedButton(
          onPressed: _isUploadingImage ? null : _onSavePressed,
          child: Text(isEditing ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}