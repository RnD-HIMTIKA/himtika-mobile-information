import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/question_bank_repository.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_chapter_map_entry.dart';

class GetAllAdminChaptersMap {
  final QuestionBankRepository repository;
  GetAllAdminChaptersMap(this.repository);

  Future<Map<String, AdminChapterMapEntry>> call() {
    return repository.getChaptersMapForAdmin();
  }
}