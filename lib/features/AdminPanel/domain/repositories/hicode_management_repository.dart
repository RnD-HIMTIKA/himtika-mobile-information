import 'dart:io';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import '../entities/admin_hicode_material.dart';

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
}