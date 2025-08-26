import '../entities/hicode_category.dart';
import '../entities/hicode_material.dart';
import '../entities/hicode_chapter.dart';

abstract class HiCodeRepository {
  Future<(List<HiCodeCategory>, List<HiCodeMaterial>, bool isExamReady)> getMainScreenData();
  Future<(String title, String description, String iconPath, List<HiCodeChapter> chapters)> getChapterListData(String materialId);
}