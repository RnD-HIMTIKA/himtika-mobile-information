import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/hicode_chapter.dart';
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

  bool get isEditing => widget.chapterToEdit != null;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeEditor();
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
          doc = Document();
        }

        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
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
    super.dispose();
  }

  // --- Kompresi Gambar ---
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

    setState(() => _isUploadingImage = true);

    try {
      final compressed = await compressImage(pickedFile);
      final fileToUpload = compressed ?? File(pickedFile.path);

      final uploadUseCase = sl<UploadHicodeImage>();
      final imageUrl = await uploadUseCase(fileToUpload, 'materi_konten');

      // Insert ke editor
      final index = _quillController!.selection.baseOffset;
      final length = _quillController!.selection.extentOffset - index;
      _quillController!.replaceText(
        index,
        length,
        BlockEmbed.image(imageUrl),
        null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar berhasil ditambahkan!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload: $e'), backgroundColor: Colors.red),
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
      if (isEditing) {
        bloc.add(UpdateChapterSubmitted(
          id: widget.chapterToEdit!.id,
          title: title,
          content: contentJson,
          estimatedReadTime: readTime,
        ));
      } else {
        bloc.add(AddChapterSubmitted(
          materialId: widget.materialId,
          title: title,
          content: contentJson,
          estimatedReadTime: readTime,
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
              TextFormField(
                controller: _readTimeController,
                decoration: const InputDecoration(
                  labelText: 'Estimasi Waktu Baca (Menit)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // --- TOOLBAR DENGAN TOMBOL GAMBAR CUSTOM ---
              QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: _quillController!,
                  multiRowsDisplay: false,
                  customButtons: [
                    QuillToolbarCustomButtonOptions(
                      icon: const Icon(Icons.image, size: 20),
                      onPressed: _insertImage,
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
                  sharedConfigurations: const QuillSharedConfigurations(locale: Locale('id')),
                ),
              ),
              const SizedBox(height: 8),

              // --- EDITOR ---
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QuillEditor(
                    controller: _quillController!,
                    scrollController: ScrollController(),
                    focusNode: FocusNode(),
                    configurations: QuillEditorConfigurations(
                      padding: const EdgeInsets.all(8),
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                    ),
                  ),
                ),
              ),

              // --- Loading Upload ---
              if (_isUploadingImage)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text("Mengunggah gambar...", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        ElevatedButton(
          onPressed: _isUploadingImage ? null : _onSavePressed,
          child: Text(isEditing ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}