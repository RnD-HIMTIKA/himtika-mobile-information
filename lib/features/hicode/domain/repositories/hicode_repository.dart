import '../entities/hicode_category.dart';
import '../entities/hicode_material.dart';
import '../entities/hicode_chapter.dart';
import '../entities/hicode_chapter_content.dart';
import '../entities/hicode_question.dart';
import '../entities/quiz_result.dart';
import '../entities/leaderboard_entry.dart';

abstract class HiCodeRepository {
  Future<
      (
        List<HiCodeCategory> categories,
        List<HiCodeMaterial> materials,
        bool allMaterialsComplete,
        bool canTakeExamToday,
        DateTime? nextExamAvailableAt
      )> getMainScreenData();
  Future<
      (
        String title,
        String description,
        String iconPath,
        List<HiCodeChapter> chapters,
        String finalPracticeStatus,
        int finalPracticeQuestionCount
      )> getChapterListData(String materialId);
  Future<HiCodeChapterContent> getChapterContent(
      String chapterId, String userId);
  Future<List<HiCodeQuestion>> getQuestions(
      String relatedId, String questionType);
  Future<QuizResult> submitAnswers(Map<String, String> answers,
      {int? timeTakenSeconds});
  Future<void> updateScrollPosition(
      String chapterId, double position, bool hasReachedBottom);
  Future<List<LeaderboardEntry>> getLeaderboard(String filter);
}
