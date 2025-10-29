import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart'; // <-- Import AdminQuestion
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_event.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_state.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question_detail.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_option_detail.dart';

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
  final List<String> _questionTypes = ['QUIZ', 'FINAL_PRACTICE', 'OVERALL_EXAM'];
  final List<String> _difficulties = ['Mudah', 'Menengah', 'Sulit'];

  @override
  void initState() {
    super.initState();
    final detail = widget.questionDetail; // Akses detail dari widget

    // --- Pre-fill data ---
    _questionTextController.text = detail.questionText;
    _selectedQuestionType = detail.questionType;
    _selectedDifficulty = detail.difficulty;
    _selectedRelatedId = detail.questionType != 'OVERALL_EXAM'
       ? detail.relatedId
       : null;

    // --- Pre-fill opsi ---
    _optionControllers = detail.options.map((opt) => TextEditingController(text: opt.optionText)).toList();
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
    if (_optionControllers.length < 5) { // Batasi maksimal 5 opsi
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maksimal 5 opsi jawaban.'), backgroundColor: Colors.orange),
       );
    }
  }

  void _removeOptionField(int index) {
    if (_optionControllers.length > 2) { // Minimal 2 opsi
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
          const SnackBar(content: Text('Minimal harus ada 2 opsi jawaban.'), backgroundColor: Colors.orange),
       );
    }
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
       if (_correctOptionIndex == null) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Pilih salah satu jawaban yang benar.'), backgroundColor: Colors.orange),
          );
          return;
       }
        if (_selectedRelatedId == null && _selectedQuestionType != 'OVERALL_EXAM') {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Pilih Chapter/Materi terkait.'), backgroundColor: Colors.orange),
          );
          return;
       }

       final options = <QuestionOptionInput>[];
       for (int i = 0; i < _optionControllers.length; i++) {
          options.add(QuestionOptionInput(
            optionText: _optionControllers[i].text.trim(),
            isCorrect: i == _correctOptionIndex,
          ));
       }

       final finalRelatedId = _selectedQuestionType == 'OVERALL_EXAM'
            ? '00000000-0000-0000-0000-000000000000'
            : _selectedRelatedId!;

       // --- Panggil Event Edit ---
       context.read<QuestionBankBloc>().add(EditQuestionSubmitted(
             questionId: widget.questionDetail.id, // <-- Gunakan ID dari detail
             relatedId: finalRelatedId,
             questionType: _selectedQuestionType!,
             difficulty: _selectedDifficulty!,
             questionText: _questionTextController.text.trim(),
             options: options,
             // imageUrl: widget.questionDetail.imageUrl, // <-- TODO: Handle image update later
           ));
       Navigator.of(context).pop();
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
          child: ListView( // Gunakan ListView agar content bisa scroll
            shrinkWrap: true,
            children: [
              // --- Dropdown Tipe Soal ---
              DropdownButtonFormField<String>(
                value: _selectedQuestionType, // Gunakan state pre-fill
                hint: const Text('Pilih Tipe Soal'),
                items: _questionTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() {
                  _selectedQuestionType = value;
                  _selectedRelatedId = null; // Reset related ID saat tipe berubah
                   // Jika tipe OVERALL_EXAM, set related ID ke placeholder (jika perlu)
                  if (value == 'OVERALL_EXAM') {
                      _selectedRelatedId = '00000000-0000-0000-0000-000000000000';
                  }
                }),
                decoration: _inputDecoration('Tipe Soal'),
                validator: (value) => value == null ? 'Tipe soal wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              // --- Dropdown Terkait Dengan (Kondisional) ---
              if (_selectedQuestionType == 'QUIZ')
                DropdownButtonFormField<String>(
                   value: _selectedRelatedId, // Gunakan state pre-fill
                   hint: const Text('Pilih Chapter Terkait'),
                   items: chaptersMap.isEmpty
                     ? [const DropdownMenuItem(enabled: false, child: Text('Memuat chapters...', style: TextStyle(color: Colors.grey)))]
                     : chaptersMap.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value, overflow: TextOverflow.ellipsis))).toList(),
                   onChanged: chaptersMap.isEmpty ? null : (value) => setState(() => _selectedRelatedId = value),
                   decoration: _inputDecoration('Chapter Terkait'),
                   validator: (value) => value == null ? 'Chapter terkait wajib dipilih' : null,
                   isExpanded: true, // Agar teks panjang terlihat
                )
              else if (_selectedQuestionType == 'FINAL_PRACTICE')
                 DropdownButtonFormField<String>(
                    value: _selectedRelatedId, // Gunakan state pre-fill
                    hint: const Text('Pilih Materi Terkait'),
                    items: materialsMap.isEmpty
                      ? [const DropdownMenuItem(enabled: false, child: Text('Memuat materi...', style: TextStyle(color: Colors.grey)))]
                      : materialsMap.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: materialsMap.isEmpty ? null : (value) => setState(() => _selectedRelatedId = value),
                    decoration: _inputDecoration('Materi Terkait'),
                    validator: (value) => value == null ? 'Materi terkait wajib dipilih' : null,
                     isExpanded: true, // Agar teks panjang terlihat
                  )
               else if (_selectedQuestionType == 'OVERALL_EXAM') // Tampilkan info jika OVERALL_EXAM
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
                items: _difficulties.map((diff) => DropdownMenuItem(value: diff, child: Text(diff))).toList(),
                onChanged: (value) => setState(() => _selectedDifficulty = value),
                decoration: _inputDecoration('Tingkat Kesulitan'),
                validator: (value) => value == null ? 'Kesulitan wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              // --- Textarea Pertanyaan ---
              TextFormField(
                controller: _questionTextController, // Gunakan controller pre-fill
                decoration: _inputDecoration('Teks Pertanyaan').copyWith(alignLabelWithHint: true),
                maxLines: 4,
                validator: (value) => (value?.trim().isEmpty ?? true) ? 'Teks pertanyaan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),

              // --- Input Opsi Jawaban Dinamis ---
              const Text('Opsi Jawaban', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Pilih salah satu sebagai jawaban benar.', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 8),
              // Gunakan Column karena jumlah opsi terbatas
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_optionControllers.length, (index) {
                   return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                           Radio<int>(
                             value: index,
                             groupValue: _correctOptionIndex, // Gunakan state pre-fill
                             onChanged: (value) => setState(() => _correctOptionIndex = value),
                             visualDensity: VisualDensity.compact,
                             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                           ),
                           Expanded(
                             child: TextFormField(
                               controller: _optionControllers[index], // Gunakan controller pre-fill
                               decoration: _inputDecoration('Opsi ${index + 1}').copyWith(
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                               ),
                                validator: (value) => (value?.trim().isEmpty ?? true) ? 'Opsi tidak boleh kosong' : null,
                             ),
                           ),
                           // Tombol Hapus Opsi
                           IconButton(
                             icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade700),
                             onPressed: () => _removeOptionField(index), // Panggil fungsi remove
                             tooltip: 'Hapus Opsi',
                             padding: EdgeInsets.zero,
                             constraints: const BoxConstraints(),
                           ),
                         ],
                      ),
                    );
                }),
              ),
              const SizedBox(height: 8),
              // Tombol Tambah Opsi
              if (_optionControllers.length < 5) // Tampilkan jika < 5
                Align(
                  alignment: Alignment.center,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Opsi'),
                    onPressed: _addOptionField, // Panggil fungsi add
                    style: OutlinedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                       textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              const SizedBox(height: 16), // Beri jarak sebelum actions
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        // Tombol Simpan dengan state loading
        BlocBuilder<QuestionBankBloc, QuestionBankState>(
           builder: (context, state) {
              return ElevatedButton(
                // Nonaktifkan tombol saat status submitting
                onPressed: state.status == QuestionBankStatus.submitting ? null : _onSavePressed,
                child: state.status == QuestionBankStatus.submitting
                  // Tampilkan loading indicator jika sedang submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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