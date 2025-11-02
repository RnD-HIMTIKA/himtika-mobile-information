import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/question_bank_repository.dart';

class GetAdminQuestions {
  final QuestionBankRepository repository;
  GetAdminQuestions(this.repository);

  // --- MODIFIKASI DI SINI ---
  Future<List<AdminQuestion>> call(
      {int limit = 50, int offset = 0, String? questionType}) {
    return repository.getAdminQuestions(
        limit: limit, offset: offset, questionType: questionType);
  }
  // --- AKHIR MODIFIKASI ---
}