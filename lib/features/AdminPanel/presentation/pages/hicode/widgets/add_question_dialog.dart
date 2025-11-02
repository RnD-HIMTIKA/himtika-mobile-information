import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:himtika_mobile_information/core/theme/app_colors.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/upload_hicode_image.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_chapter_map_entry.dart';

class AddQuestionDialog extends StatefulWidget {
  const AddQuestionDialog({super.key});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();

  // State untuk form
  String? _selectedQuestionType; // QUIZ, FINAL_PRACTICE, OVERALL_EXAM
  String? _selectedDifficulty; // Mudah, Menengah, Sulit
  String? _selectedRelatedId; // ID Chapter atau Materi

  // State untuk opsi dinamis
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController()
  ];
  int? _correctOptionIndex; // Index dari opsi yang benar

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Gagal mengompres gambar.'),
              backgroundColor: Colors.orange));
        }
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
      String? finalQuestionImageUrl; // Add dialog starts with null
      if (_questionImageFile != null) {
        print("Uploading question image...");
        finalQuestionImageUrl = await uploadUseCase(_questionImageFile!, 'soal');
        print("Question image uploaded: $finalQuestionImageUrl");
      }
      // Jika tidak ada file baru DAN tidak ada URL lama, finalQuestionImageUrl akan jadi null (sesuai harapan)

      // 3. Upload/Persiapkan URL Gambar Opsi & Buat List Opsi Final
      final List<QuestionOptionInput> finalOptions = [];
    for (int i = 0; i < _optionControllers.length; i++) {
      String? finalOptionImageUrl; // Add dialog starts with null
      if (_optionImageFiles.containsKey(i) && _optionImageFiles[i] != null) {
        print("Uploading option image for index $i...");
        finalOptionImageUrl = await uploadUseCase(_optionImageFiles[i]!, 'opsi');
        print("Option image uploaded: $finalOptionImageUrl");
      }
      finalOptions.add(QuestionOptionInput(
        optionText: _optionControllers[i].text.trim(),
        isCorrect: i == _correctOptionIndex,
        imageUrl: finalOptionImageUrl,
      ));
    }

      // 4. Tentukan finalRelatedId
      final finalRelatedId = _selectedQuestionType == 'OVERALL_EXAM'
          ? '00000000-0000-0000-0000-000000000000' // Pastikan konsisten
          : _selectedRelatedId!;

      // 5. Kirim Event BLoC (Add atau Edit)
      final bloc = context.read<QuestionBankBloc>();

      print("Dispatching AddQuestionSubmitted");
      bloc.add(AddQuestionSubmitted(
            relatedId: finalRelatedId,
            questionType: _selectedQuestionType!,
            difficulty: _selectedDifficulty!,
            questionText: _questionTextController.text.trim(),
            imageUrl: finalQuestionImageUrl,
            options: finalOptions,
          ));

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
    final state = context.watch<QuestionBankBloc>().state;
    final Map<String, AdminChapterMapEntry> chaptersMap = state.chaptersMap;
    final materialsMap = state.materialsMap;

    return AlertDialog(
      title: const Text('Tambah Soal Baru'),
      // Atur padding content agar tidak terlalu mepet
      contentPadding:
          const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0), // Atur padding
      // Bungkus content dengan Container yang diberi lebar
      content: SizedBox(
        // Beri lebar agar tidak infinite, misal 90% lebar layar
        width: MediaQuery.of(context).size.width * 0.9,
        // HAPUS scrollable: true dari AlertDialog
        child: Form(
          key: _formKey,
          // Gunakan ListView SEBAGAI WIDGET UTAMA KONTEN
          // agar AlertDialog bisa scroll kontennya
          child: ListView(
            shrinkWrap:
                true, // Penting agar ListView tidak mengambil tinggi tak terbatas di sini
            children: [
              // --- Dropdown Tipe Soal ---
              DropdownButtonFormField<String>(
                value: _selectedQuestionType,
                hint: const Text('Pilih Tipe Soal'),
                items: _questionTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedQuestionType = value;
                  _selectedRelatedId = null;
                }),
                decoration: _inputDecoration('Tipe Soal'),
                validator: (value) =>
                    value == null ? 'Tipe soal wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              // --- Dropdown Terkait Dengan (Kondisional) ---
              // (Logika dropdown kondisional tetap sama seperti sebelumnya)
              if (_selectedQuestionType == 'QUIZ')
                DropdownButtonFormField<String>(
                  /* ... Dropdown Chapter ... */
                  value: _selectedRelatedId,
                  hint: const Text('Pilih Chapter Terkait'),
                  items: chaptersMap.isEmpty
                      ? [
                          const DropdownMenuItem(
                              enabled: false,
                              child: Text('Belum ada chapter',
                                  style: TextStyle(color: Colors.grey)))
                        ]
                      : chaptersMap.entries
                          .map((entry) => DropdownMenuItem(
                              value: entry.key, // <-- key adalah ID Chapter
                              child: Text(entry.value.title, // <-- value.title adalah Teks
                                  overflow: TextOverflow.ellipsis)))
                          .toList(),
                  onChanged: chaptersMap.isEmpty
                      ? null
                      : (value) => setState(() => _selectedRelatedId = value),
                  decoration: _inputDecoration('Chapter Terkait'),
                  validator: (value) =>
                      value == null ? 'Chapter terkait wajib dipilih' : null,
                  isExpanded: true,
                )
              else if (_selectedQuestionType == 'FINAL_PRACTICE')
                DropdownButtonFormField<String>(
                  /* ... Dropdown Materi ... */
                  value: _selectedRelatedId,
                  hint: const Text('Pilih Materi Terkait'),
                  items: materialsMap.isEmpty
                      ? [
                          const DropdownMenuItem(
                              enabled: false,
                              child: Text('Belum ada materi',
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
                  isExpanded: true,
                )
              else if (_selectedQuestionType != null)
                Padding(
                  /* ... Teks Info OVERALL_EXAM ... */
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                      'Tipe OVERALL_EXAM tidak perlu Chapter/Materi terkait.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ),
              // Tambahkan SizedBox jika dropdown tidak muncul
              if (!(['QUIZ', 'FINAL_PRACTICE']
                      .contains(_selectedQuestionType)) &&
                  _selectedQuestionType != null)
                const SizedBox(height: 16),

              // --- Dropdown Kesulitan ---
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
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
              const SizedBox(height: 16),

              // --- Textarea Pertanyaan ---
              TextFormField(
                controller: _questionTextController,
                decoration: _inputDecoration('Teks Pertanyaan')
                    .copyWith(alignLabelWithHint: true),
                maxLines: 4,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Teks pertanyaan tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),

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
                    onPressed: _addOptionField,
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
      actionsPadding: const EdgeInsets.fromLTRB(
          20.0, 0.0, 20.0, 16.0), // Atur padding actions
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal')),
        BlocBuilder<QuestionBankBloc, QuestionBankState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state.status == QuestionBankStatus.submitting
                  ? null
                  : _onSavePressed,
              child: state.status == QuestionBankStatus.submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan Soal'),
            );
          },
        ),
      ],
    );
  }

  // Helper untuk InputDecoration agar konsisten
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      // Atur padding content agar tidak terlalu tinggi
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      isDense: true, // Buat lebih compact
    );
  }
}
