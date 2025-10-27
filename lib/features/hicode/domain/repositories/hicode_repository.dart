import '../entities/hicode_category.dart';
import '../entities/hicode_material.dart';
import '../entities/hicode_chapter.dart';
import '../entities/hicode_chapter_content.dart';
import '../entities/hicode_question.dart';
import '../entities/quiz_result.dart';

abstract class HiCodeRepository {
  Future<(List<HiCodeCategory>, List<HiCodeMaterial>, bool isExamReady)> getMainScreenData();
  Future<(String title, String description, String iconPath, List<HiCodeChapter> chapters, String finalPracticeStatus)> getChapterListData(String materialId);
  Future<HiCodeChapterContent> getChapterContent(String chapterId);
  Future<List<HiCodeQuestion>> getQuestions(String relatedId, String questionType);
  Future<QuizResult> submitAnswers(Map<String, String> answers);
}