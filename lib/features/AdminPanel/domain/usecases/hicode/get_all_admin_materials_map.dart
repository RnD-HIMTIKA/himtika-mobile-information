import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/question_bank_repository.dart';

class GetAllAdminMaterialsMap {
  final QuestionBankRepository repository;
  GetAllAdminMaterialsMap(this.repository);

  Future<Map<String, String>> call() {
    return repository.getMaterialsMapForAdmin();
  }
}