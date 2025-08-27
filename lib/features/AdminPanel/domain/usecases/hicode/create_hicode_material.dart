import 'dart:io';
import '../../repositories/hicode_management_repository.dart';

class CreateHiCodeMaterial {
  final HiCodeManagementRepository repository;
  CreateHiCodeMaterial(this.repository);

  Future<void> call({
    required String categoryId,
    required String title,
    required String description,
    required File imageFile,
    required String borderColor,
  }) {
    if (title.trim().isEmpty || description.trim().isEmpty || borderColor.trim().isEmpty) {
      throw Exception('Semua field harus diisi.');
    }
    if (!borderColor.trim().startsWith('#') || borderColor.trim().length != 7) {
      throw Exception('Format Warna Border tidak valid (contoh: #FF5733).');
    }
    return repository.createMaterial(
      categoryId: categoryId,
      title: title,
      description: description,
      imageFile: imageFile,
      borderColor: borderColor,
    );
  }
}