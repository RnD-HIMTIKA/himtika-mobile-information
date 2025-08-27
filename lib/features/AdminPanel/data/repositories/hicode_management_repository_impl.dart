import 'dart:io';
import 'package:himtika_mobile_information/features/AdminPanel/data/models/admin_hicode_material_model.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_hicode_material.dart';
import 'package:himtika_mobile_information/features/hicode/data/models/hicode_category_model.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import '../../domain/repositories/hicode_management_repository.dart';
import '../datasources/hicode_management_remote_datasource.dart';

class HiCodeManagementRepositoryImpl implements HiCodeManagementRepository {
  final HiCodeManagementRemoteDatasource remoteDatasource;

  HiCodeManagementRepositoryImpl({required this.remoteDatasource});

  // --- Kategori ---
  @override
  Future<List<HiCodeCategory>> getCategories() async {
    final data = await remoteDatasource.getCategories();
    return data.map((map) => HiCodeCategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> createCategory({required String name, required File iconFile}) async {
    final iconUrl = await remoteDatasource.uploadIcon(iconFile: iconFile);
    await remoteDatasource.createCategory(name: name, iconUrl: iconUrl);
  }

  @override
  Future<void> updateCategory({required String id, required String name, File? iconFile}) async {
    String? newIconUrl;
    if (iconFile != null) {
      newIconUrl = await remoteDatasource.uploadIcon(iconFile: iconFile);
    }
    await remoteDatasource.updateCategory(id: id, name: name, iconUrl: newIconUrl);
  }

  @override
  Future<void> deleteCategory({required String id}) {
    return remoteDatasource.deleteCategory(id: id);
  }

  // --- Materi (BARU) ---
  @override
  Future<List<AdminHiCodeMaterial>> getAdminMaterials() async {
    final data = await remoteDatasource.getAdminMaterials();
    // Anda perlu membuat AdminHiCodeMaterialModel
    return data.map((map) => AdminHiCodeMaterialModel.fromMap(map)).toList();
  }

  @override
  Future<void> createMaterial({
    required String categoryId,
    required String title,
    required String description,
    required File imageFile,
    required String borderColor,
  }) async {
    final imageUrl = await remoteDatasource.uploadMaterialImage(imageFile: imageFile);
    await remoteDatasource.createMaterial(
      categoryId: categoryId,
      title: title,
      description: description,
      imageUrl: imageUrl,
      borderColor: borderColor,
    );
  }
}