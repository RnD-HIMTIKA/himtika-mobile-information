import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/question_bank_repository.dart';

class CreateQuestionWithOptions {
  final QuestionBankRepository repository;
  CreateQuestionWithOptions(this.repository);

  Future<String> call({
    required String relatedId,
    required String questionType,
    required String difficulty,
    required String questionText,
    String? imageUrl,
    required List<QuestionOptionInput> options,
  }) {
    // Validasi dasar bisa ditambahkan di sini jika perlu
    if (questionText.trim().isEmpty) {
       throw Exception('Teks pertanyaan tidak boleh kosong.');
    }
    if (options.length < 2) {
       throw Exception('Minimal harus ada 2 opsi jawaban.');
    }
    final correctCount = options.where((opt) => opt.isCorrect).length;
    if (correctCount != 1) {
       throw Exception('Harus ada tepat satu opsi jawaban yang benar.');
    }
    // Pastikan relatedId tidak kosong jika type bukan OVERALL_EXAM
    if (questionType != 'OVERALL_EXAM' && relatedId.trim().isEmpty) {
       throw Exception('Harus memilih Chapter atau Materi terkait.');
    }


    return repository.createQuestionWithOptions(
      relatedId: relatedId,
      questionType: questionType,
      difficulty: difficulty,
      questionText: questionText,
      imageUrl: imageUrl,
      options: options,
    );
  }
}