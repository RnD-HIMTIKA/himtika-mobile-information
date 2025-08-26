import 'dart:io';
import 'package:himtika_mobile_information/features/hicode/data/models/hicode_category_model.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import '../../domain/repositories/hicode_management_repository.dart';
import '../datasources/hicode_management_remote_datasource.dart';

class HiCodeManagementRepositoryImpl implements HiCodeManagementRepository {
  final HiCodeManagementRemoteDatasource remoteDatasource;

  HiCodeManagementRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<HiCodeCategory>> getCategories() async {
    final data = await remoteDatasource.getCategories();
    return data.map((map) => HiCodeCategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> createCategory({required String name, required File iconFile}) async {
    // 1. Unggah ikon terlebih dahulu
    final iconUrl = await remoteDatasource.uploadIcon(iconFile: iconFile);
    
    // 2. Gunakan URL yang didapat untuk membuat kategori di database
    await remoteDatasource.createCategory(name: name, iconUrl: iconUrl);
  }

  @override
  Future<void> updateCategory({required String id, required String name, File? iconFile}) async {
    String? newIconUrl;
    // Jika ada file ikon baru, unggah terlebih dahulu
    if (iconFile != null) {
      newIconUrl = await remoteDatasource.uploadIcon(iconFile: iconFile);
    }
    
    // Panggil RPC untuk update. RPC akan menangani jika newIconUrl null.
    // Kita perlu memodifikasi RPC di Supabase agar bisa menangani URL null.
    await remoteDatasource.updateCategory(id: id, name: name, iconUrl: newIconUrl);
  }

  @override
  Future<void> deleteCategory({required String id}) {
    return remoteDatasource.deleteCategory(id: id);
  }
}