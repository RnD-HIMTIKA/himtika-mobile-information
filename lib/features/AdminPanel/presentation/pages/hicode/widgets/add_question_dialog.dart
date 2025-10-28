import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_event.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_state.dart';

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
  List<TextEditingController> _optionControllers = [TextEditingController(), TextEditingController()];
  int? _correctOptionIndex; // Index dari opsi yang benar

  // Tipe data soal
  final List<String> _questionTypes = ['QUIZ', 'FINAL_PRACTICE', 'OVERALL_EXAM'];
  final List<String> _difficulties = ['Mudah', 'Menengah', 'Sulit'];

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

        // Untuk OVERALL_EXAM, related_id bisa dikirim sebagai UUID kosong atau nilai spesifik
       final finalRelatedId = _selectedQuestionType == 'OVERALL_EXAM'
            ? '00000000-0000-0000-0000-000000000000' // Atau null jika RPC handle
            : _selectedRelatedId!;


       context.read<QuestionBankBloc>().add(AddQuestionSubmitted(
             relatedId: finalRelatedId,
             questionType: _selectedQuestionType!,
             difficulty: _selectedDifficulty!,
             questionText: _questionTextController.text.trim(),
             options: options,
             // imageUrl: null, // Tambahkan nanti
           ));
       Navigator.of(context).pop();
    }
  }

  @override
Widget build(BuildContext context) {
  final state = context.watch<QuestionBankBloc>().state;
  final chaptersMap = state.chaptersMap;
  final materialsMap = state.materialsMap;

  return AlertDialog(
    title: const Text('Tambah Soal Baru'),
    // Atur padding content agar tidak terlalu mepet
    contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0), // Atur padding
    // Bungkus content dengan Container yang diberi lebar
    content: Container(
      // Beri lebar agar tidak infinite, misal 90% lebar layar
      width: MediaQuery.of(context).size.width * 0.9,
      // HAPUS scrollable: true dari AlertDialog
      child: Form(
        key: _formKey,
        // Gunakan ListView SEBAGAI WIDGET UTAMA KONTEN
        // agar AlertDialog bisa scroll kontennya
        child: ListView(
          shrinkWrap: true, // Penting agar ListView tidak mengambil tinggi tak terbatas di sini
          children: [
            // --- Dropdown Tipe Soal ---
            DropdownButtonFormField<String>(
              value: _selectedQuestionType,
              hint: const Text('Pilih Tipe Soal'),
              items: _questionTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) => setState(() {
                _selectedQuestionType = value;
                _selectedRelatedId = null;
              }),
              decoration: _inputDecoration('Tipe Soal'),
              validator: (value) => value == null ? 'Tipe soal wajib dipilih' : null,
            ),
            const SizedBox(height: 16),

            // --- Dropdown Terkait Dengan (Kondisional) ---
            // (Logika dropdown kondisional tetap sama seperti sebelumnya)
            if (_selectedQuestionType == 'QUIZ')
              DropdownButtonFormField<String>( /* ... Dropdown Chapter ... */
                 value: _selectedRelatedId,
                 hint: const Text('Pilih Chapter Terkait'),
                 items: chaptersMap.isEmpty
                   ? [const DropdownMenuItem(enabled: false, child: Text('Belum ada chapter', style: TextStyle(color: Colors.grey)))]
                   : chaptersMap.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value, overflow: TextOverflow.ellipsis))).toList(),
                 onChanged: chaptersMap.isEmpty ? null : (value) => setState(() => _selectedRelatedId = value),
                 decoration: _inputDecoration('Chapter Terkait'),
                 validator: (value) => value == null ? 'Chapter terkait wajib dipilih' : null,
                 isExpanded: true,
              )
            else if (_selectedQuestionType == 'FINAL_PRACTICE')
               DropdownButtonFormField<String>( /* ... Dropdown Materi ... */
                  value: _selectedRelatedId,
                  hint: const Text('Pilih Materi Terkait'),
                  items: materialsMap.isEmpty
                    ? [const DropdownMenuItem(enabled: false, child: Text('Belum ada materi', style: TextStyle(color: Colors.grey)))]
                    : materialsMap.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: materialsMap.isEmpty ? null : (value) => setState(() => _selectedRelatedId = value),
                  decoration: _inputDecoration('Materi Terkait'),
                  validator: (value) => value == null ? 'Materi terkait wajib dipilih' : null,
                   isExpanded: true,
                )
             else if (_selectedQuestionType != null)
               Padding( /* ... Teks Info OVERALL_EXAM ... */
                 padding: const EdgeInsets.symmetric(vertical: 8.0),
                 child: Text('Tipe OVERALL_EXAM tidak perlu Chapter/Materi terkait.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
               ),
            // Tambahkan SizedBox jika dropdown tidak muncul
            if (!(['QUIZ', 'FINAL_PRACTICE'].contains(_selectedQuestionType)) && _selectedQuestionType != null)
              const SizedBox(height: 16),


            // --- Dropdown Kesulitan ---
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              hint: const Text('Pilih Tingkat Kesulitan'),
              items: _difficulties.map((diff) => DropdownMenuItem(value: diff, child: Text(diff))).toList(),
              onChanged: (value) => setState(() => _selectedDifficulty = value),
              decoration: _inputDecoration('Tingkat Kesulitan'),
              validator: (value) => value == null ? 'Kesulitan wajib dipilih' : null,
            ),
            const SizedBox(height: 16),

            // --- Textarea Pertanyaan ---
            TextFormField(
              controller: _questionTextController,
              decoration: _inputDecoration('Teks Pertanyaan').copyWith(alignLabelWithHint: true),
              maxLines: 4,
              validator: (value) => (value?.trim().isEmpty ?? true) ? 'Teks pertanyaan tidak boleh kosong' : null,
            ),
            const SizedBox(height: 24),

            // --- Input Opsi Jawaban Dinamis ---
            const Text('Opsi Jawaban', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Pilih salah satu sebagai jawaban benar.', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 8),
            // Gunakan Column untuk opsi karena jumlahnya terbatas (max 5)
            // Ini menghindari masalah layout dengan ListView di dalam AlertDialog
            Column(
              mainAxisSize: MainAxisSize.min, // Penting
              children: List.generate(_optionControllers.length, (index) {
                 return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                         Radio<int>(
                           value: index,
                           groupValue: _correctOptionIndex,
                           onChanged: (value) => setState(() => _correctOptionIndex = value),
                           visualDensity: VisualDensity.compact,
                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                         ),
                         Expanded(
                           child: TextFormField(
                             controller: _optionControllers[index],
                             decoration: _inputDecoration('Opsi ${index + 1}').copyWith(
                               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                             ),
                              validator: (value) => (value?.trim().isEmpty ?? true) ? 'Opsi tidak boleh kosong' : null,
                           ),
                         ),
                         IconButton(
                           icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade700),
                           onPressed: () => _removeOptionField(index),
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
            if (_optionControllers.length < 5) // Tampilkan hanya jika < 5
              Align(
                alignment: Alignment.center,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Opsi'),
                  onPressed: _addOptionField,
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
    actionsPadding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0), // Atur padding actions
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
      BlocBuilder<QuestionBankBloc, QuestionBankState>(
         builder: (context, state) {
            return ElevatedButton(
              onPressed: state.status == QuestionBankStatus.submitting ? null : _onSavePressed,
              child: state.status == QuestionBankStatus.submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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