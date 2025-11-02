import 'package:himtika_mobile_information/features/AdminPanel/data/datasources/question_bank_remote_datasource.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/question_bank_repository.dart';
import 'package:himtika_mobile_information/features/AdminPanel/data/models/admin_question_detail_model.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question_detail.dart';

class QuestionBankRepositoryImpl implements QuestionBankRepository {
  final QuestionBankRemoteDatasource remoteDatasource;
  QuestionBankRepositoryImpl({required this.remoteDatasource});

  @override
  // --- MODIFIKASI DI SINI ---
  Future<List<AdminQuestion>> getAdminQuestions(
      {int limit = 50, int offset = 0, String? questionType}) async {
    final data = await remoteDatasource.getAdminQuestions(
        limit: limit, offset: offset, questionType: questionType);
    // --- AKHIR MODIFIKASI ---
    return data
        .map((map) => AdminQuestion(
              id: map['id'],
              questionText: map['question_text'],
              questionType: map['question_type'],
              difficulty: map['difficulty'],
              relatedId: map['related_id'] as String?,
              relatedTitle: map['related_title'],
              optionCount: map['option_count'] ?? 0,
              createdAt: DateTime.parse(map['created_at']),
            ))
        .toList();
  }

  @override
  Future<String> createQuestionWithOptions({
    required String relatedId,
    required String questionType,
    required String difficulty,
    required String questionText,
    String? imageUrl,
    required List<QuestionOptionInput> options,
  }) {
    return remoteDatasource.createQuestionWithOptions(
      relatedId: relatedId,
      questionType: questionType,
      difficulty: difficulty,
      questionText: questionText,
      imageUrl: imageUrl,
      options: options,
    );
  }

  // Implementasi method baru
  @override
  Future<void> updateQuestionWithOptions({
    required String questionId,
    required String relatedId,
    required String questionType,
    required String difficulty,
    required String questionText,
    String? imageUrl,
    required List<QuestionOptionInput> options,
  }) {
     return remoteDatasource.updateQuestionWithOptions(
       questionId: questionId,
       relatedId: relatedId,
       questionType: questionType,
       difficulty: difficulty,
       questionText: questionText,
       imageUrl: imageUrl,
       options: options,
     );
  }

  @override
  Future<void> deleteQuestion({required String questionId}) {
     return remoteDatasource.deleteQuestion(questionId: questionId);
  }

  @override
  Future<AdminQuestionDetail> getQuestionDetails({required String questionId}) async {
    final data = await remoteDatasource.getQuestionDetails(questionId: questionId);
    // Map hasil Map<String, dynamic> ke Entity menggunakan Model
    return AdminQuestionDetailModel.fromMap(data);
  }
  
  // Method map tetap ada
  @override
  Future<Map<String, String>> getChaptersMapForAdmin() async {
    final data = await remoteDatasource.getChaptersForAdmin();
    return { for (var item in data) item['id'].toString() : item['title'].toString() };
  }

  @override
  Future<Map<String, String>> getMaterialsMapForAdmin() async {
    final data = await remoteDatasource.getMaterialsForAdmin();
    return { for (var item in data) item['id'].toString() : item['title'].toString() };
  }
}