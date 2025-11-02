import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';

abstract class HiCodeManagementRemoteDatasource {
  // Operasi CRUD Kategori
  Future<List<Map<String, dynamic>>> getCategories();
  Future<void> createCategory({required String name, required String iconUrl});
  Future<void> updateCategory({required String id, required String name, String? iconUrl});
  Future<void> deleteCategory({required String id});
  Future<String> uploadIcon({required File iconFile});

  // Operasi CRUD Materi
  Future<List<Map<String, dynamic>>> getAdminMaterials();
  Future<void> createMaterial({
    required String categoryId,
    required String title,
    required String description,
    required String imageUrl,
    required String borderColor,
  });
  Future<void> updateMaterial({
    required String id,
    required String categoryId,
    required String title,
    required String description,
    String? imageUrl, // Opsional
    required String borderColor,
  });
  Future<void> deleteMaterial({required String id});
  Future<String> uploadMaterialImage({required File imageFile});
  // Operasi CRUD Chapter (BARU)
  Future<List<Map<String, dynamic>>> getChaptersByMaterial(String materialId);
  Future<void> createChapter({
    required String materialId,
    required String title,
    required List<dynamic> content,
    int? estimatedReadTime,
    required int order,
  });
  Future<void> updateChapter({
    required String id,
    String? title,
    List<dynamic>? content,
    int? estimatedReadTime,
    int? order,
  });
  Future<void> deleteChapter(String id);
  Future<void> reorderChapters(String materialId, List<String> chapterIds);
}

class HiCodeManagementRemoteDatasourceImpl implements HiCodeManagementRemoteDatasource {
  final SupabaseClient client;
  HiCodeManagementRemoteDatasourceImpl({required this.client});

  // --- Existing Kategori Implementations ---
  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await client.rpc('get_hicode_categories');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  @override
  Future<void> createCategory({required String name, required String iconUrl}) async {
    await client.rpc('create_hicode_category', params: {'p_name': name, 'p_icon_url': iconUrl});
  }

  @override
  Future<void> updateCategory({required String id, required String name, String? iconUrl}) async {
    await client.rpc('update_hicode_category', params: {'p_id': id, 'p_name': name, 'p_icon_url': iconUrl});
  }

  @override
  Future<void> deleteCategory({required String id}) async {
    await client.rpc('delete_hicode_category', params: {'p_id': id});
  }

  @override
  Future<String> uploadIcon({required File iconFile}) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${basename(iconFile.path)}';
      const bucketName = 'hicode_assets';
      final filePath = 'icon/$fileName';

      await client.storage.from(bucketName).upload(filePath, iconFile);
      return client.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Gagal mengunggah ikon: $e');
    }
  }

  // --- Existing Materi Implementations ---
  @override
  Future<List<Map<String, dynamic>>> getAdminMaterials() async {
    final data = await client.rpc('get_admin_hicode_materials');
    return List<Map<String, dynamic>>.from(data ?? []);
  }
  
  @override
  Future<void> createMaterial({
    required String categoryId,
    required String title,
    required String description,
    required String imageUrl,
    required String borderColor,
  }) async {
    await client.rpc('create_hicode_material', params: {
      'p_category_id': categoryId,
      'p_title': title,
      'p_description': description,
      'p_image_url': imageUrl,
      'p_border_color': borderColor,
    });
  }

  @override
  Future<String> uploadMaterialImage({required File imageFile}) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${basename(imageFile.path)}';
      const bucketName = 'hicode_assets';
      final filePath = 'images/$fileName';

      await client.storage.from(bucketName).upload(filePath, imageFile);
      return client.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Gagal mengunggah gambar materi: $e');
    }
  }

  @override
  Future<void> updateMaterial({
    required String id,
    required String categoryId,
    required String title,
    required String description,
    String? imageUrl, // Opsional
    required String borderColor,
  }) async {
    await client.rpc('update_hicode_material', params: {
      'p_id': id,
      'p_category_id': categoryId,
      'p_title': title,
      'p_description': description,
      'p_image_url': imageUrl, // RPC-55
      'p_border_color': borderColor,
    });
  }
  
  @override
  Future<void> deleteMaterial({required String id}) async {
    // Memanggil RPC yang sudah ada
    await client.rpc('delete_hicode_material', params: {'p_id': id});
  }

  // --- Chapter Implementations (BARU) ---
  @override
  Future<List<Map<String, dynamic>>> getChaptersByMaterial(String materialId) async {
    final response = await client
        .from('hicode_chapters')
        .select()
        .eq('material_id', materialId)
        .order('order');
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> createChapter({
    required String materialId,
    required String title,
    required List<dynamic> content,
    int? estimatedReadTime,
    required int order,
  }) async {
    await client.from('hicode_chapters').insert({
      'material_id': materialId,
      'title': title,
      'content': content,
      'estimated_read_time': estimatedReadTime,
      'order': order,
    });
  }

  @override
  Future<void> updateChapter({
    required String id,
    String? title,
    List<dynamic>? content,
    int? estimatedReadTime,
    int? order,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    // Kirim List<dynamic>? langsung sebagai nilai 'content' (jsonb)
    if (content != null) updates['content'] = content; // <-- Kirim List<dynamic>?
    if (estimatedReadTime != null) updates['estimated_read_time'] = estimatedReadTime;
    if (order != null) updates['order'] = order;

    if (updates.isNotEmpty) {
      await client.from('hicode_chapters').update(updates).eq('id', id);
    }
  }

  @override
  Future<void> deleteChapter(String id) async {
    await client.from('hicode_chapters').delete().eq('id', id);
  }

  @override
  Future<void> reorderChapters(String materialId, List<String> chapterIds) async {
    // Update order berdasarkan posisi dalam list
    for (int i = 0; i < chapterIds.length; i++) {
      await client
          .from('hicode_chapters')
          .update({'order': i + 1})
          .eq('id', chapterIds[i]);
    }
  }
}