import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/question_bank_repository.dart';

class DeleteQuestion {
  final QuestionBankRepository repository;
  DeleteQuestion(this.repository);

  Future<void> call({required String questionId}) {
     if (questionId.trim().isEmpty) {
      throw Exception('ID Pertanyaan tidak valid.');
    }
    return repository.deleteQuestion(questionId: questionId);
  }
}