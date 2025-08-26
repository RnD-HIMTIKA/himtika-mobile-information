import 'package:himtika_mobile_information/features/hicode/domain/entities/quiz_result.dart';
import '../repositories/hicode_repository.dart';

class SubmitQuizAnswers {
  final HiCodeRepository repository;
  SubmitQuizAnswers(this.repository);

  Future<QuizResult> call(Map<String, String> answers) {
    // Validasi: pastikan ada jawaban yang dikirim
    if (answers.isEmpty) {
      throw Exception('Tidak ada jawaban yang dipilih.');
    }
    return repository.submitAnswers(answers);
  }
}