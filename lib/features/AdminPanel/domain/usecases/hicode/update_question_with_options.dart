import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/question_bank_repository.dart';

class UpdateQuestionWithOptions {
  final QuestionBankRepository repository;
  UpdateQuestionWithOptions(this.repository);

  Future<void> call({
    required String questionId, // ID soal yang akan diupdate
    required String relatedId,
    required String questionType,
    required String difficulty,
    required String questionText,
    String? imageUrl,
    required List<QuestionOptionInput> options,
  }) {
    // Validasi dasar (mirip dengan Create)
    if (questionId.trim().isEmpty) {
       throw Exception('ID Pertanyaan tidak valid.');
    }
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
    if (questionType != 'OVERALL_EXAM' && relatedId.trim().isEmpty) {
       throw Exception('Harus memilih Chapter atau Materi terkait.');
    }

    return repository.updateQuestionWithOptions(
      questionId: questionId,
      relatedId: relatedId,
      questionType: questionType,
      difficulty: difficulty,
      questionText: questionText,
      imageUrl: imageUrl,
      options: options,
    );
  }
}