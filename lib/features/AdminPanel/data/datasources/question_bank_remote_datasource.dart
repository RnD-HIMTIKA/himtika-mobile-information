// Untuk jsonEncode
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';

abstract class QuestionBankRemoteDatasource {
  Future<List<Map<String, dynamic>>> getAdminQuestions({int limit = 50, int offset = 0});
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
  Future<Map<String, dynamic>> getQuestionDetails({required String questionId});
  // Method map tetap ada
  Future<List<Map<String, dynamic>>> getChaptersForAdmin();
  Future<List<Map<String, dynamic>>> getMaterialsForAdmin();
}

class QuestionBankRemoteDatasourceImpl implements QuestionBankRemoteDatasource {
  final SupabaseClient client;
  QuestionBankRemoteDatasourceImpl({required this.client});

  @override
  Future<List<Map<String, dynamic>>> getAdminQuestions({int limit = 50, int offset = 0}) async {
    final data = await client.rpc('get_hicode_questions_admin', params: {
      'p_limit': limit,
      'p_offset': offset,
    });
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  @override
  Future<String> createQuestionWithOptions({
    required String relatedId,
    required String questionType,
    required String difficulty,
    required String questionText,
    String? imageUrl,
    required List<QuestionOptionInput> options,
  }) async {
    final optionsPayload = options.map((opt) => opt.toJson()).toList();
    final newQuestionId = await client.rpc('create_hicode_question_with_options', params: {
        'p_related_id': relatedId,
        'p_question_type': questionType,
        'p_difficulty': difficulty,
        'p_question_text': questionText,
        'p_image_url': imageUrl,
        'p_options': optionsPayload,
    });
    return newQuestionId as String;
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
  }) async {
     final optionsPayload = options.map((opt) => opt.toJson()).toList();
     await client.rpc('update_hicode_question_with_options', params: {
        'p_question_id': questionId, // <-- ID Soal
        'p_related_id': relatedId,
        'p_question_type': questionType,
        'p_difficulty': difficulty,
        'p_question_text': questionText,
        'p_image_url': imageUrl,
        'p_options': optionsPayload,
     });
  }

  @override
  Future<void> deleteQuestion({required String questionId}) async {
     await client.rpc('delete_hicode_question', params: {
        'p_question_id': questionId, // <-- ID Soal
     });
  }

  @override
  Future<Map<String, dynamic>> getQuestionDetails({required String questionId}) async {
     // Panggil RPC get_question_details
     final data = await client.rpc('get_question_details', params: {
        'p_question_id': questionId,
     });
     // Hasil RPC adalah satu objek JSON
     if (data == null) {
       throw Exception('Detail soal tidak ditemukan.');
     }
     return data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getChaptersForAdmin() async {
    final data = await client.rpc('get_all_chapters_for_admin');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  @override
  Future<List<Map<String, dynamic>>> getMaterialsForAdmin() async {
    final data = await client.rpc('get_all_materials_for_admin');
    return List<Map<String, dynamic>>.from(data ?? []);
  }
}