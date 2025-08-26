import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';

abstract class HiCodeManagementRemoteDatasource {
  // Operasi CRUD Kategori
  Future<List<Map<String, dynamic>>> getCategories();
  Future<void> createCategory({required String name, required String iconUrl});
  Future<void> updateCategory({required String id, required String name, String? iconUrl});
  Future<void> deleteCategory({required String id});

  // Operasi File Storage
  Future<String> uploadIcon({required File iconFile});
}

class HiCodeManagementRemoteDatasourceImpl implements HiCodeManagementRemoteDatasource {
  final SupabaseClient client;
  HiCodeManagementRemoteDatasourceImpl({required this.client});

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await client.rpc('get_hicode_categories');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  @override
  Future<void> createCategory({required String name, required String iconUrl}) async {
    await client.rpc('create_hicode_category', params: {
      'p_name': name,
      'p_icon_url': iconUrl,
    });
  }

  @override
  Future<void> updateCategory({required String id, required String name, String? iconUrl}) async {
    // Kita akan membuat RPC baru yang lebih fleksibel untuk ini nanti.
    // Untuk sekarang, kita panggil RPC yang ada dengan logika null check di repository.
    await client.rpc('update_hicode_category', params: {
      'p_id': id,
      'p_name': name,
      'p_icon_url': iconUrl, // RPC akan menangani jika ini null
    });
  }

  @override
  Future<void> deleteCategory({required String id}) async {
    await client.rpc('delete_hicode_category', params: {'p_id': id});
  }

  @override
  Future<String> uploadIcon({required File iconFile}) async {
    try {
      // Buat path file yang unik untuk menghindari penimpaan
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${basename(iconFile.path)}';
      const bucketName = 'hicode_assets';
      final filePath = 'icon/$fileName'; // Simpan di dalam folder 'icon'

      // Unggah file ke Supabase Storage
      await client.storage.from(bucketName).upload(filePath, iconFile);

      // Dapatkan URL publik dari file yang baru diunggah
      final String publicUrl = client.storage.from(bucketName).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      // Tangani kemungkinan error saat unggah
      throw Exception('Gagal mengunggah ikon: $e');
    }
  }
}