import 'package:himtika_mobile_information/features/AdminPanel/data/datasources/question_bank_remote_datasource.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/question_bank_repository.dart';

class QuestionBankRepositoryImpl implements QuestionBankRepository {
  final QuestionBankRemoteDatasource remoteDatasource;
  QuestionBankRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<AdminQuestion>> getAdminQuestions({int limit = 50, int offset = 0}) async {
    final data = await remoteDatasource.getAdminQuestions(limit: limit, offset: offset);
    // Mapping dari Map ke Entity AdminQuestion
    return data.map((map) => AdminQuestion(
      id: map['id'],
      questionText: map['question_text'],
      questionType: map['question_type'],
      difficulty: map['difficulty'],
      relatedId: map['related_id'] as String?, // Ambil related_id (bisa null)
      relatedTitle: map['related_title'],
      optionCount: map['option_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    )).toList();
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
    // Langsung teruskan ke datasource
    return remoteDatasource.createQuestionWithOptions(
      relatedId: relatedId,
      questionType: questionType,
      difficulty: difficulty,
      questionText: questionText,
      imageUrl: imageUrl,
      options: options,
    );
  }

  @override
  Future<Map<String, String>> getChaptersMapForAdmin() async {
    final data = await remoteDatasource.getChaptersForAdmin();
    // Konversi List<Map> ke Map<String, String>
    return { for (var item in data) item['id'].toString() : item['title'].toString() };
  }

  @override
  Future<Map<String, String>> getMaterialsMapForAdmin() async {
    final data = await remoteDatasource.getMaterialsForAdmin();
    // Konversi List<Map> ke Map<String, String>
    return { for (var item in data) item['id'].toString() : item['title'].toString() };
  }
}