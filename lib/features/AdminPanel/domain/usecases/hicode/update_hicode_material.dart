import 'dart:io';
import '../../repositories/hicode_management_repository.dart';

class UpdateHiCodeMaterial {
  final HiCodeManagementRepository repository;
  UpdateHiCodeMaterial(this.repository);

  Future<void> call({
    required String id,
    required String categoryId,
    required String title,
    required String description,
    File? imageFile, // Gambar bersifat opsional saat update
    required String borderColor,
  }) {
    if (id.trim().isEmpty || title.trim().isEmpty || description.trim().isEmpty || borderColor.trim().isEmpty) {
      throw Exception('ID, Judul, Deskripsi, dan Warna Border tidak boleh kosong.');
    }
    if (!borderColor.trim().startsWith('#') || borderColor.trim().length != 7) {
      throw Exception('Format Warna Border tidak valid (contoh: #FF5733).');
    }
    
    return repository.updateMaterial(
      id: id,
      categoryId: categoryId,
      title: title,
      description: description,
      imageFile: imageFile, // Teruskan file opsional
      borderColor: borderColor,
    );
  }
}