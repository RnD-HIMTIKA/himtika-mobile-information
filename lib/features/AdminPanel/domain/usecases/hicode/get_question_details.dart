import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question_detail.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/question_bank_repository.dart';

class GetQuestionDetails {
  final QuestionBankRepository repository;
  GetQuestionDetails(this.repository);

  Future<AdminQuestionDetail> call({required String questionId}) {
     if (questionId.trim().isEmpty) {
      throw Exception('ID Pertanyaan tidak valid.');
    }
    return repository.getQuestionDetails(questionId: questionId);
  }
}