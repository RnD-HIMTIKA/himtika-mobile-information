import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question_detail.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_chapter_map_entry.dart';

abstract class QuestionBankRepository {
  Future<List<AdminQuestion>> getAdminQuestions(
      {int limit = 50, int offset = 0, String? questionType, String? relatedId}); // <-- TAMBAHKAN
  Future<String> createQuestionWithOptions({
    required String relatedId,
    required String questionType,
    required String difficulty,
    required String questionText,
    String? imageUrl,
    required List<QuestionOptionInput> options,
  });
  Future<void> updateQuestionWithOptions({
    required String questionId,
    required String relatedId,
    required String questionType,
    required String difficulty,
    required String questionText,
    String? imageUrl,
    required List<QuestionOptionInput> options,
  });
  Future<void> deleteQuestion({required String questionId});
  Future<AdminQuestionDetail> getQuestionDetails({required String questionId});
  Future<Map<String, AdminChapterMapEntry>> getChaptersMapForAdmin();
  Future<Map<String, String>> getMaterialsMapForAdmin();
}