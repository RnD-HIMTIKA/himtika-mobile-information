import 'dart:convert'; // Untuk jsonEncode
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
  Future<List<Map<String, dynamic>>> getChaptersForAdmin();
  Future<List<Map<String, dynamic>>> getMaterialsForAdmin();
}

class QuestionBankRemoteDatasourceImpl implements QuestionBankRemoteDatasource {
  final SupabaseClient client;
  QuestionBankRemoteDatasourceImpl({required this.client});

  @override
  Future<List<Map<String, dynamic>>> getAdminQuestions({int limit = 50, int offset = 0}) async {
    // Panggil RPC get_hicode_questions_admin
    final data = await client.rpc('get_hicode_questions_admin', params: {
      'p_limit': limit,
      'p_offset': offset,
    });
    // Hasil RPC adalah list of maps (karena return type TABLE)
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

    // Panggil RPC create_hicode_question_with_options
    final newQuestionId = await client.rpc('create_hicode_question_with_options', params: {
        'p_related_id': relatedId,
        'p_question_type': questionType,
        'p_difficulty': difficulty,
        'p_question_text': questionText,
        'p_image_url': imageUrl, // Akan null jika tidak diberikan
        'p_options': optionsPayload, // Kirim sebagai JSON
    });
    // Kembalikan ID pertanyaan baru
    return newQuestionId as String;
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