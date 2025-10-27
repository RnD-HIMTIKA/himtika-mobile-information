import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_chapter.dart';
import '../repositories/hicode_repository.dart';

class GetChapterListData {
  final HiCodeRepository repository;
  GetChapterListData(this.repository);

  Future<(String title, String description, String iconPath, List<HiCodeChapter> chapters, String finalPracticeStatus)> call(String materialId) {
    return repository.getChapterListData(materialId);
  }
}