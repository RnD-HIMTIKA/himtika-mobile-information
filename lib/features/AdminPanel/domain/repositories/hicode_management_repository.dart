import 'dart:io';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';

abstract class HiCodeManagementRepository {
  Future<List<HiCodeCategory>> getCategories();
  Future<void> createCategory({required String name, required File iconFile});
  Future<void> updateCategory({required String id, required String name, File? iconFile});
  Future<void> deleteCategory({required String id});
}