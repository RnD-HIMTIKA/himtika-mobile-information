import 'package:supabase_flutter/supabase_flutter.dart';
// Tambahkan import ini jika belum ada
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';


abstract class HiCodeRemoteDatasource {
  Future<Map<String, dynamic>> getMainScreenData();
  Future<Map<String, dynamic>> getChapterListData(String materialId);
  Future<Map<String, dynamic>> getChapterContent(String chapterId, String userId);
  Future<List<Map<String, dynamic>>> getQuestions(String relatedId, String questionType);
  Future<Map<String, dynamic>> submitAnswers(Map<String, String> answers);
  Future<void> updateScrollPosition(String chapterId, double position, bool hasReachedBottom);
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
    final data = await client.rpc('get_hicode_questions', params: {
      'p_related_id': relatedId,
      'p_question_type': questionType,
    });
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  @override
  Future<Map<String, dynamic>> submitAnswers(Map<String, String> answers) async {
    final user = await getCurrentUser();
     if (user == null) {
       throw Exception('Pengguna tidak terautentikasi saat mencoba submit jawaban.');
     }

    final answersPayload = answers.entries.map((entry) => {
        'questionId': entry.key, // UUID Soal (String)
        'optionId': entry.value   // UUID Opsi (String)
    }).toList();

    // Panggil RPC dengan user.id dan payload jawaban yang baru
    final result = await client.rpc('submit_hicode_answers', params: {
        'p_user_id': user.id,          // Kirim ID user
        'p_answers': answersPayload   // Kirim List<Map>
    });
    // Pastikan hasil RPC di-cast dengan benar
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
}