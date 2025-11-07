import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';

abstract class HiCodeRemoteDatasource {
  Future<Map<String, dynamic>> getMainScreenData();
  Future<Map<String, dynamic>> getChapterListData(String materialId);
  Future<Map<String, dynamic>> getChapterContent(String chapterId, String userId);
  Future<List<Map<String, dynamic>>> getQuestions(String relatedId, String questionType);
  Future<Map<String, dynamic>> submitAnswers(Map<String, String> answers, {int? timeTakenSeconds});
  Future<void> updateScrollPosition(String chapterId, double position, bool hasReachedBottom);
  Future<List<Map<String, dynamic>>> getLeaderboard(String filter);
}

class HiCodeRemoteDatasourceImpl implements HiCodeRemoteDatasource {
  final SupabaseClient client;
  // Tambahkan dependency GetCurrentUser untuk mendapatkan user_id
  final GetCurrentUser getCurrentUser;

  HiCodeRemoteDatasourceImpl({required this.client, required this.getCurrentUser}); // Update constructor

  @override
  Future<Map<String, dynamic>> getMainScreenData() async {
    // Dapatkan user ID saat ini
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }
    // Panggil RPC yang sebenarnya
    final data = await client.rpc(
      'get_hicode_main_screen',
      params: {'p_user_id': user.id}, // Kirim user ID
    );
    // Hasil RPC adalah objek tunggal, bukan list, jadi langsung return
    return data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getChapterListData(String materialId) async {
    // Dapatkan user ID saat ini
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }
    // Panggil RPC yang sebenarnya
    final data = await client.rpc(
      'get_chapter_list',
      params: {
        'p_user_id': user.id, // Kirim user ID
        'p_material_id': materialId,
      },
    );
    // Hasil RPC adalah objek tunggal
    return data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getChapterContent(String chapterId, String userId) async {
    // Panggil RPC dengan kedua parameter
    return await client.rpc('get_hicode_chapter_content', params: {
      'p_chapter_id': chapterId,
      'p_user_id': userId, // Kirim user ID
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getQuestions(String relatedId, String questionType) async {
    // Panggil RPC yang mengembalikan SETOF hicode_question_with_options_type
    final data = await client.rpc('get_hicode_questions', params: {
      'p_related_id': relatedId,
      'p_question_type': questionType,
    });
    // Hasilnya sudah List<Map<String, dynamic>>, langsung return
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  @override
  // Modifikasi implementasi method ini
  Future<Map<String, dynamic>> submitAnswers(Map<String, String> answers, {int? timeTakenSeconds}) async {
    final user = await getCurrentUser();
     if (user == null) {
       throw Exception('Pengguna tidak terautentikasi saat mencoba submit jawaban.');
     }

    final answersPayload = answers.entries.map((entry) => {
        'questionId': entry.key,
        'optionId': entry.value
    }).toList();

    // Panggil RPC dengan parameter baru
    final result = await client.rpc('submit_hicode_answers', params: {
        'p_user_id': user.id,
        'p_answers': answersPayload,
        'p_time_taken_seconds': timeTakenSeconds // <-- Teruskan parameter waktu
    });
    return result as Map<String, dynamic>;
  }

  @override
  Future<void> updateScrollPosition(String chapterId, double position, bool hasReachedBottom) async {
     final user = await getCurrentUser();
     if (user == null) {
       throw Exception('Pengguna tidak terautentikasi.');
     }
     await client.rpc('update_scroll_position', params: {
        'p_user_id': user.id,
        'p_chapter_id': chapterId,
        'p_position': position,
        'p_has_reached_bottom': hasReachedBottom,
     });
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard(String filter) async { // <-- Tambahkan ini nanti
    final data = await client.rpc('get_leaderboard', params: {'p_filter': filter});
    return List<Map<String, dynamic>>.from(data ?? []);
  }
}