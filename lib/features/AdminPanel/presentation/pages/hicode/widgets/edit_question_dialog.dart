import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:himtika_mobile_information/core/theme/app_colors.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart'; // <-- Import AdminQuestion
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_event.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_state.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question_detail.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_option_detail.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/upload_hicode_image.dart';

class EditQuestionDialog extends StatefulWidget {
  final AdminQuestionDetail questionDetail;
  const EditQuestionDialog({super.key, required this.questionDetail});

  @override
  State<EditQuestionDialog> createState() => _EditQuestionDialogState();
}

class _EditQuestionDialogState extends State<EditQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();

  String? _selectedQuestionType;
  String? _selectedDifficulty;
  String? _selectedRelatedId;

  // Ubah state opsi
  List<TextEditingController> _optionControllers = [];
  int? _correctOptionIndex;

  // Tipe data soal
  final List<String> _questionTypes = [
    'QUIZ',
    'FINAL_PRACTICE',
    'OVERALL_EXAM'
  ];
  final List<String> _difficulties = ['Mudah', 'Menengah', 'Sulit'];

  File? _questionImageFile; // File gambar soal yang dipilih
  String?
      _existingQuestionImageUrl; // URL gambar soal yang sudah ada (untuk Edit)
  final Map<int, File?> _optionImageFiles =
      {}; // File gambar opsi yang dipilih (key: index opsi)
  final Map<int, String?> _optionImageUrls =
      {}; // URL gambar opsi yang sudah ada (untuk Edit, key: index opsi)

  final ImagePicker _picker = ImagePicker(); // Instance ImagePicker
  bool _isUploading = false; // Flag untuk loading saat upload

  // Fungsi kompresi
  Future<File?> compressImage(XFile imageFile) async {
    final filePath = imageFile.path;
    // Gunakan alias p untuk basename
    final fileName = p.basename(filePath);
    final lastIndex =
        fileName.lastIndexOf('.'); // Cari titik terakhir untuk ekstensi
    String splitted = "";
    String extension = "";
    if (lastIndex != -1) {
      splitted = fileName.substring(0, (lastIndex));
      extension = fileName.substring(lastIndex);
    } else {
      splitted = fileName; // Jika tidak ada ekstensi
    }

    // Buat path sementara untuk output
    final dir = Directory.systemTemp;
    final outPath = "${dir.path}/${splitted}_out$extension";

    Uint8List? result = await FlutterImageCompress.compressWithFile(
      filePath,
      minWidth: 1080, // Maks lebar 1080px
      quality: 75, // Kualitas 75%
    );

    if (result != null) {
      final file = File(outPath)..writeAsBytesSync(result);
      print('Original path: $filePath');
      print('Compressed path: $outPath');
      print('Compressed size: ${file.lengthSync()} bytes');
      return file;
    }
    print('Compression failed');
    return null;
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage({int? optionIndex}) async {
    if (_isUploading) return; // Jangan izinkan pilih gambar saat sedang upload
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File? compressedFile = await compressImage(pickedFile);
      if (compressedFile != null) {
        setState(() {
          if (optionIndex == null) {
            // Untuk Soal
            _questionImageFile = compressedFile;
            _existingQuestionImageUrl = null;
          } else {
            // Untuk Opsi
            _optionImageFiles[optionIndex] = compressedFile;
            _optionImageUrls[optionIndex] = null;
          }
        });
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Gagal mengompres gambar.'),
              backgroundColor: Colors.orange));
      }
    }
  }

  // Fungsi untuk menghapus gambar
  void _removeImage({int? optionIndex}) {
    setState(() {
      if (optionIndex == null) {
        _questionImageFile = null;
        _existingQuestionImageUrl = null;
      } else {
        _optionImageFiles.remove(optionIndex);
        _optionImageUrls.remove(optionIndex);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final detail = widget.questionDetail; // Akses detail dari widget

    // --- Pre-fill data ---
    _questionTextController.text = detail.questionText;
    _selectedQuestionType = detail.questionType;
    _selectedDifficulty = detail.difficulty;
    _selectedRelatedId =
        detail.questionType != 'OVERALL_EXAM' ? detail.relatedId : null;

    // --- Pre-fill opsi ---
    _optionControllers = detail.options
        .map((opt) => TextEditingController(text: opt.optionText))
        .toList();
    // Cari index opsi yang benar
    _correctOptionIndex = detail.options.indexWhere((opt) => opt.isCorrect);
    // Jika tidak ditemukan (seharusnya tidak terjadi), set null

    if (_correctOptionIndex == -1) {
      _correctOptionIndex = null;
    }
    // Pastikan minimal ada 2 controller jika data opsi kurang dari 2 (jarang terjadi)
    while (_optionControllers.length < 2) {
      _optionControllers.add(TextEditingController());
    }

    _existingQuestionImageUrl =
        widget.questionDetail.imageUrl; // Simpan URL yang ada

    // Inisialisasi URL opsi yang ada
    for (int i = 0; i < widget.questionDetail.options.length; i++) {
      _optionImageUrls[i] = widget.questionDetail.options[i].imageUrl;
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOptionField() {
    if (_optionControllers.length < 5) {
      // Batasi maksimal 5 opsi
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Maksimal 5 opsi jawaban.'),
            backgroundColor: Colors.orange),
      );
    }
  }

  void _removeOptionField(int index) {
    if (_optionControllers.length > 2) {
      // Minimal 2 opsi
      // Jika opsi yang dihapus adalah yang benar, reset _correctOptionIndex
      if (_correctOptionIndex == index) {
        _correctOptionIndex = null;
      } else if (_correctOptionIndex != null && _correctOptionIndex! > index) {
        // Geser index jawaban benar jika perlu
        _correctOptionIndex = _correctOptionIndex! - 1;
      }
      setState(() {
        _optionControllers[index].dispose(); // Hapus controller
        _optionControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Minimal harus ada 2 opsi jawaban.'),
            backgroundColor: Colors.orange),
      );
    }
  }

  void _onSavePressed() async {
    // 1. Validasi Form Lokal
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_correctOptionIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih salah satu jawaban yang benar.'),
          backgroundColor: Colors.orange));
      return;
    }
    if (_selectedRelatedId == null && _selectedQuestionType != 'OVERALL_EXAM') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih Chapter/Materi terkait.'),
          backgroundColor: Colors.orange));
      return;
    }

    // --- Mulai Proses Upload & Submit ---
    setState(() => _isUploading = true); // Tampilkan loading indicator

    try {
      final uploadUseCase = sl<UploadHicodeImage>(); // Dapatkan use case upload

      // 2. Upload/Persiapkan URL Gambar Soal
      String? finalQuestionImageUrl =
          _existingQuestionImageUrl; // Ambil URL lama (hanya ada di edit)
      if (_questionImageFile != null) {
        // Jika ada file baru dipilih
        print("Uploading question image...");
        finalQuestionImageUrl =
            await uploadUseCase(_questionImageFile!, 'soal');
        print("Question image uploaded: $finalQuestionImageUrl");
      }
      // Jika tidak ada file baru DAN tidak ada URL lama, finalQuestionImageUrl akan jadi null (sesuai harapan)

      // 3. Upload/Persiapkan URL Gambar Opsi & Buat List Opsi Final
      final List<QuestionOptionInput> finalOptions = [];
      for (int i = 0; i < _optionControllers.length; i++) {
        String? finalOptionImageUrl =
            _optionImageUrls[i]; // Ambil URL lama (hanya ada di edit)
        if (_optionImageFiles.containsKey(i) && _optionImageFiles[i] != null) {
          // Jika ada file baru
          print("Uploading option image for index $i...");
          finalOptionImageUrl =
              await uploadUseCase(_optionImageFiles[i]!, 'opsi');
          print("Option image uploaded: $finalOptionImageUrl");
        }
        // Tambahkan ke list opsi final
        finalOptions.add(QuestionOptionInput(
          optionText: _optionControllers[i].text.trim(),
          isCorrect: i == _correctOptionIndex,
          imageUrl: finalOptionImageUrl, // Masukkan URL hasil upload/lama/null
        ));
      }

      // 4. Tentukan finalRelatedId
      final finalRelatedId = _selectedQuestionType == 'OVERALL_EXAM'
          ? '00000000-0000-0000-0000-000000000000' // Pastikan konsisten
          : _selectedRelatedId!;

      // 5. Kirim Event BLoC (Add atau Edit)
      final bloc = context.read<QuestionBankBloc>();
      if (widget is EditQuestionDialog) {
        final questionId = (widget as EditQuestionDialog).questionDetail.id;
        print("Dispatching EditQuestionSubmitted for ID: $questionId");
        bloc.add(EditQuestionSubmitted(
          questionId: questionId,
          relatedId: finalRelatedId,
          questionType: _selectedQuestionType!,
          difficulty: _selectedDifficulty!,
          questionText: _questionTextController.text.trim(),
          imageUrl: finalQuestionImageUrl,
          options: finalOptions,
        ));
      } else {
        print("Dispatching AddQuestionSubmitted");
        bloc.add(AddQuestionSubmitted(
          relatedId: finalRelatedId,
          questionType: _selectedQuestionType!,
          difficulty: _selectedDifficulty!,
          questionText: _questionTextController.text.trim(),
          imageUrl: finalQuestionImageUrl,
          options: finalOptions,
        ));
      }

      if (mounted) Navigator.of(context).pop(); // Tutup dialog jika berhasil
    } catch (e) {
      // Tangani error upload/submit
      print("Error during save: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      // Pastikan loading dihentikan meskipun error
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil state BLoC untuk mendapatkan map chapter & materi
    final state = context.watch<QuestionBankBloc>().state;
    final chaptersMap = state.chaptersMap;
    final materialsMap = state.materialsMap;

    return AlertDialog(
      title: const Text('Edit Soal'), // Judul dialog Edit
      contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
      content: Container(
        // Beri lebar agar dialog tidak terlalu sempit
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: ListView(
            // Gunakan ListView agar content bisa scroll
            shrinkWrap: true,
            children: [
              // --- Dropdown Tipe Soal ---
              DropdownButtonFormField<String>(
                value: _selectedQuestionType, // Gunakan state pre-fill
                hint: const Text('Pilih Tipe Soal'),
                items: _questionTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedQuestionType = value;
                  _selectedRelatedId =
                      null; // Reset related ID saat tipe berubah
                  // Jika tipe OVERALL_EXAM, set related ID ke placeholder (jika perlu)
                  if (value == 'OVERALL_EXAM') {
                    _selectedRelatedId = '00000000-0000-0000-0000-000000000000';
                  }
                }),
                decoration: _inputDecoration('Tipe Soal'),
                validator: (value) =>
                    value == null ? 'Tipe soal wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              // --- Dropdown Terkait Dengan (Kondisional) ---
              if (_selectedQuestionType == 'QUIZ')
                DropdownButtonFormField<String>(
                  value: _selectedRelatedId, // Gunakan state pre-fill
                  hint: const Text('Pilih Chapter Terkait'),
                  items: chaptersMap.isEmpty
                      ? [
                          const DropdownMenuItem(
                              enabled: false,
                              child: Text('Memuat chapters...',
                                  style: TextStyle(color: Colors.grey)))
                        ]
                      : chaptersMap.entries
                          .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value,
                                  overflow: TextOverflow.ellipsis)))
                          .toList(),
                  onChanged: chaptersMap.isEmpty
                      ? null
                      : (value) => setState(() => _selectedRelatedId = value),
                  decoration: _inputDecoration('Chapter Terkait'),
                  validator: (value) =>
                      value == null ? 'Chapter terkait wajib dipilih' : null,
                  isExpanded: true, // Agar teks panjang terlihat
                )
              else if (_selectedQuestionType == 'FINAL_PRACTICE')
                DropdownButtonFormField<String>(
                  value: _selectedRelatedId, // Gunakan state pre-fill
                  hint: const Text('Pilih Materi Terkait'),
                  items: materialsMap.isEmpty
                      ? [
                          const DropdownMenuItem(
                              enabled: false,
                              child: Text('Memuat materi...',
                                  style: TextStyle(color: Colors.grey)))
                        ]
                      : materialsMap.entries
                          .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value,
                                  overflow: TextOverflow.ellipsis)))
                          .toList(),
                  onChanged: materialsMap.isEmpty
                      ? null
                      : (value) => setState(() => _selectedRelatedId = value),
                  decoration: _inputDecoration('Materi Terkait'),
                  validator: (value) =>
                      value == null ? 'Materi terkait wajib dipilih' : null,
                  isExpanded: true, // Agar teks panjang terlihat
                )
              else if (_selectedQuestionType ==
                  'OVERALL_EXAM') // Tampilkan info jika OVERALL_EXAM
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Tipe OVERALL_EXAM tidak perlu Chapter/Materi terkait.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              // Tambah SizedBox jika dropdown "Terkait Dengan" tidak muncul
              if (!(['QUIZ', 'FINAL_PRACTICE'].contains(_selectedQuestionType)))
                const SizedBox(height: 16),

              // --- Dropdown Kesulitan ---
              DropdownButtonFormField<String>(
                value: _selectedDifficulty, // Gunakan state pre-fill
                hint: const Text('Pilih Tingkat Kesulitan'),
                items: _difficulties
                    .map((diff) =>
                        DropdownMenuItem(value: diff, child: Text(diff)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedDifficulty = value),
                decoration: _inputDecoration('Tingkat Kesulitan'),
                validator: (value) =>
                    value == null ? 'Kesulitan wajib dipilih' : null,
              ),
              const SizedBox(height: 16), // Jarak sebelum gambar soal

// --- Bagian Gambar Soal ---
              const Text('Gambar Soal (Opsional)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 150, // Sesuaikan tinggi preview
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100, // Warna background
                ),
                child: Stack(
                  // Gunakan Stack agar tombol hapus bisa overlay
                  alignment: Alignment.center,
                  children: [
                    // Tampilkan preview gambar
                    if (_questionImageFile != null)
                      Image.file(_questionImageFile!, fit: BoxFit.contain)
                    else if (_existingQuestionImageUrl != null &&
                        _existingQuestionImageUrl!.isNotEmpty)
                      Image.network(
                        _existingQuestionImageUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) =>
                            loadingProgress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator()),
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    else // Placeholder jika tidak ada gambar
                      const Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 40),

                    // Tombol Hapus Gambar (Overlay pojok kanan atas)
                    if (_questionImageFile != null ||
                        (_existingQuestionImageUrl != null &&
                            _existingQuestionImageUrl!.isNotEmpty))
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          tooltip: 'Hapus Gambar Soal',
                          onPressed: _isUploading
                              ? null
                              : () => _removeImage(), // Disable saat upload
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.7)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                // Pusatkan tombol pilih gambar
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(_questionImageFile != null ||
                          (_existingQuestionImageUrl != null &&
                              _existingQuestionImageUrl!.isNotEmpty)
                      ? 'Ganti Gambar Soal'
                      : 'Pilih Gambar Soal'),
                  onPressed: _isUploading
                      ? null
                      : () => _pickImage(), // Disable saat upload
                ),
              ),
              const SizedBox(height: 24), // Jarak sebelum opsi

// --- Input Opsi Jawaban Dinamis ---
              const Text('Opsi Jawaban',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Pilih salah satu sebagai jawaban benar.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 8),
// Gunakan Column agar tidak overflow di dalam ListView
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_optionControllers.length, (index) {
                  final bool hasExistingImage =
                      _optionImageUrls.containsKey(index) &&
                          _optionImageUrls[index] != null &&
                          _optionImageUrls[index]!.isNotEmpty;
                  final bool hasNewImage =
                      _optionImageFiles.containsKey(index) &&
                          _optionImageFiles[index] != null;
                  final bool showImagePreview = hasNewImage || hasExistingImage;

                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12.0), // Jarak antar opsi
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align top
                      children: [
                        // --- Radio Button ---
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0), // Sesuaikan agar sejajar textfield
                          child: Radio<int>(
                            value: index,
                            groupValue: _correctOptionIndex,
                            onChanged: _isUploading
                                ? null
                                : (value) => setState(() =>
                                    _correctOptionIndex =
                                        value), // Disable saat upload
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        // --- Kolom Teks, Gambar, Tombol Opsi ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- Text Field Opsi ---
                              TextFormField(
                                controller: _optionControllers[index],
                                enabled: !_isUploading, // Disable saat upload
                                decoration:
                                    _inputDecoration('Opsi ${index + 1}')
                                        .copyWith(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                                validator: (value) =>
                                    (value?.trim().isEmpty ?? true)
                                        ? 'Opsi tidak boleh kosong'
                                        : null,
                              ),
                              const SizedBox(height: 6),
                              // --- Preview & Tombol Gambar Opsi ---
                              if (showImagePreview)
                                Container(
                                  height: 80,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (hasNewImage)
                                        Image.file(_optionImageFiles[index]!,
                                            fit: BoxFit.contain)
                                      else if (hasExistingImage)
                                        Image.network(
                                          _optionImageUrls[index]!,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child,
                                                  loadingProgress) =>
                                              loadingProgress == null
                                                  ? child
                                                  : const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    )),
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.broken_image,
                                                      color: Colors.grey),
                                        ),
                                      Positioned(
                                        // Tombol Hapus Opsi
                                        top: 2, right: 2,
                                        child: IconButton(
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.red, size: 20),
                                          tooltip: 'Hapus Gambar Opsi',
                                          onPressed: _isUploading
                                              ? null
                                              : () => _removeImage(
                                                  optionIndex: index),
                                          style: IconButton.styleFrom(
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.7)),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Tombol Tambah/Ganti Gambar Opsi
                              OutlinedButton.icon(
                                icon: Icon(
                                    showImagePreview
                                        ? Icons.edit_outlined
                                        : Icons.add_photo_alternate_outlined,
                                    size: 16),
                                label: Text(
                                    showImagePreview
                                        ? 'Ganti Gambar'
                                        : 'Tambah Gambar',
                                    style: const TextStyle(fontSize: 12)),
                                onPressed: _isUploading
                                    ? null
                                    : () => _pickImage(
                                        optionIndex:
                                            index), // Disable saat upload
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // --- Tombol Hapus Opsi ---
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 4.0), // Sesuaikan posisi
                          child: IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: Colors.red.shade700),
                            onPressed: _isUploading
                                ? null
                                : () => _removeOptionField(
                                    index), // Disable saat upload
                            tooltip: 'Hapus Opsi',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
// Tombol Tambah Opsi
              if (_optionControllers.length < 5 &&
                  !_isUploading) // Sembunyikan saat upload
                Align(
                  alignment: Alignment.center,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Opsi'),
                    onPressed: _addOptionField, // Panggil fungsi add
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              const SizedBox(height: 16), // Beri jarak sebelum actions
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal')),
        // Tombol Simpan dengan state loading
        BlocBuilder<QuestionBankBloc, QuestionBankState>(
          builder: (context, state) {
            return ElevatedButton(
              // Nonaktifkan tombol saat status submitting
              onPressed: state.status == QuestionBankStatus.submitting
                  ? null
                  : _onSavePressed,
              child: state.status == QuestionBankStatus.submitting
                  // Tampilkan loading indicator jika sedang submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  // Tampilkan teks normal jika tidak submitting
                  : const Text('Simpan Perubahan'), // Ubah teks tombol
            );
          },
        ),
      ],
    );
  }

  // Helper InputDecoration (Sama seperti Add Dialog)
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      isDense: true,
    );
  }
}
