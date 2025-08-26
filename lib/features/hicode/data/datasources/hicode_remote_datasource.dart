import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HiCodeRemoteDatasource {
  Future<Map<String, dynamic>> getMainScreenData();
  Future<Map<String, dynamic>> getChapterListData(String materialId);
  Future<Map<String, dynamic>> getChapterContent(String chapterId);
}

class HiCodeRemoteDatasourceImpl implements HiCodeRemoteDatasource {
  final SupabaseClient client;
  HiCodeRemoteDatasourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> getMainScreenData() async {
    // Diasumsikan fungsi RPC ini akan dibuat di Fase 1 nanti
    // Untuk sekarang, kita siapkan panggilannya.
    // return await client.rpc('get_hicode_main_screen');
    // Data dummy sementara agar tidak error:
    await Future.delayed(const Duration(seconds: 1));
    return {
      'categories': [],
      'materials': [],
      'is_exam_ready': false,
    };
  }

  @override
  Future<Map<String, dynamic>> getChapterListData(String materialId) async {
    // Diasumsikan fungsi RPC ini akan dibuat di Fase 1 nanti
    // return await client.rpc('get_chapter_list', params: {'p_material_id': materialId});
    // Data dummy sementara agar tidak error:
    await Future.delayed(const Duration(seconds: 1));
    return {
      'title': 'Dummy Title',
      'description': 'Dummy Description',
      'icon_path': 'src/features/hicode/materi/html.png',
      'chapters': [],
    };
  }

  @override
  Future<Map<String, dynamic>> getChapterContent(String chapterId) async {
    return await client.rpc('get_hicode_chapter_content', params: {'p_chapter_id': chapterId});
  }
}