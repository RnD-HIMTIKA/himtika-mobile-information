import 'dart:io';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import '../entities/admin_hicode_material.dart';
import '../entities/hicode_chapter.dart';

abstract class HiCodeManagementRepository {
  Future<List<HiCodeCategory>> getCategories();
  Future<void> createCategory({required String name, required File iconFile});
  Future<void> updateCategory({required String id, required String name, File? iconFile});
  Future<void> deleteCategory({required String id});

  // --- Materi (TAMBAHAN BARU) ---
  Future<List<AdminHiCodeMaterial>> getAdminMaterials();
  Future<void> createMaterial({
    required String categoryId,
    required String title,
    required String description,
    required File imageFile,
    required String borderColor,
  });

  Future<List<HiCodeChapter>> getChaptersByMaterial(String materialId);
  Future<void> createChapter({
    required String materialId,
    required String title,
    required Map<String, dynamic> content,
    int? estimatedReadTime,
    required int order,
  });
  Future<void> updateChapter({
    required String id,
    String? title,
    Map<String, dynamic>? content,
    int? estimatedReadTime,
    int? order,
  });
  Future<void> deleteChapter(String id);
  Future<void> reorderChapters(String materialId, List<String> chapterIds);
}