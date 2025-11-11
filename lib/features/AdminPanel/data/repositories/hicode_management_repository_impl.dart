import 'dart:io';
import 'package:himtika_mobile_information/features/AdminPanel/data/models/admin_hicode_material_model.dart';
import 'package:himtika_mobile_information/features/AdminPanel/data/models/hicode_chapter_model.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_hicode_material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/hicode_chapter.dart';
import 'package:himtika_mobile_information/features/hicode/data/models/hicode_category_model.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import '../../domain/repositories/hicode_management_repository.dart';
import '../datasources/hicode_management_remote_datasource.dart';

class HiCodeManagementRepositoryImpl implements HiCodeManagementRepository {
  final HiCodeManagementRemoteDatasource remoteDatasource;

  HiCodeManagementRepositoryImpl({required this.remoteDatasource});

  // --- Existing Kategori Methods ---
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

  // --- Existing Materi Methods ---
  @override
  Future<List<AdminHiCodeMaterial>> getAdminMaterials() async {
    final data = await remoteDatasource.getAdminMaterials();
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

  @override
  Future<void> updateMaterial({
    required String id,
    required String categoryId,
    required String title,
    required String description,
    File? imageFile,
    required String borderColor,
  }) async {
    String? newImageUrl;
    if (imageFile != null) {
      newImageUrl = await remoteDatasource.uploadMaterialImage(imageFile: imageFile);
    }
    await remoteDatasource.updateMaterial(
      id: id,
      categoryId: categoryId,
      title: title,
      description: description,
      imageUrl: newImageUrl,
      borderColor: borderColor,
    );
  }

  @override
  Future<void> deleteMaterial({required String id}) {
    return remoteDatasource.deleteMaterial(id: id);
  }

  @override
  Future<List<HiCodeChapter>> getChaptersByMaterial(String materialId) async {
    final data = await remoteDatasource.getChaptersByMaterial(materialId);
    // Pastikan HiCodeChapterModel.fromMap sudah diupdate
    return data.map((map) => HiCodeChapterModel.fromMap(map)).toList();
  }

  @override
  Future<void> createChapter({
    required String materialId,
    required String title,
    required List<dynamic> content,
    int? estimatedReadTime,
    required int order,
    required bool isQuizless,
  }) {
    return remoteDatasource.createChapter(
      materialId: materialId,
      title: title,
      content: content,
      estimatedReadTime: estimatedReadTime,
      order: order,
      isQuizless: isQuizless,
    );
  }

  @override
  Future<void> updateChapter({
    required String id,
    String? title,
    List<dynamic>? content,
    int? estimatedReadTime,
    int? order,
    bool? isQuizless,
  }) {
    return remoteDatasource.updateChapter(
      id: id,
      title: title,
      content: content,
      estimatedReadTime: estimatedReadTime,
      order: order,
      isQuizless: isQuizless,
    );
  }

  @override
  Future<void> deleteChapter(String id) {
    return remoteDatasource.deleteChapter(id);
  }

  @override
  Future<void> reorderChapters(String materialId, List<String> chapterIds) {
    return remoteDatasource.reorderChapters(materialId, chapterIds);
  }
}