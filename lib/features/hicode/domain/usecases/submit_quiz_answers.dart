import 'package:himtika_mobile_information/features/hicode/domain/entities/quiz_result.dart';
import '../repositories/hicode_repository.dart';

class SubmitQuizAnswers {
  final HiCodeRepository repository;
  SubmitQuizAnswers(this.repository);

  // Tambahkan parameter timeTakenSeconds (opsional, karena hanya relevan untuk Ujian Akhir)
  Future<QuizResult> call(Map<String, String> answers, {int? timeTakenSeconds}) {
    // Validasi: pastikan ada jawaban yang dikirim
    if (answers.isEmpty) {
      throw Exception('Tidak ada jawaban yang dipilih.');
    }
    // Teruskan timeTakenSeconds ke repository
    return repository.submitAnswers(answers, timeTakenSeconds: timeTakenSeconds);
  }
}