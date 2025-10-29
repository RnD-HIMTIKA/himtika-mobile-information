import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';

abstract class QuestionBankRepository {
  Future<List<AdminQuestion>> getAdminQuestions({int limit = 50, int offset = 0});
  Future<String> createQuestionWithOptions({
    required String relatedId,
    required String questionType,
    required String difficulty,
    required String questionText,
    String? imageUrl,
    required List<QuestionOptionInput> options,
  });
  // Tambahkan method baru
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
  // Method map tetap ada
  Future<Map<String, String>> getChaptersMapForAdmin();
  Future<Map<String, String>> getMaterialsMapForAdmin();
}