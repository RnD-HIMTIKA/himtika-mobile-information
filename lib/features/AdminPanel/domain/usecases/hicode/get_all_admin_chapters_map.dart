import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/question_bank_repository.dart';

class GetAllAdminChaptersMap {
  final QuestionBankRepository repository;
  GetAllAdminChaptersMap(this.repository);

  Future<Map<String, String>> call() {
    return repository.getChaptersMapForAdmin();
  }
}