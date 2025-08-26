import 'dart:io';
import '../../repositories/hicode_management_repository.dart';

class CreateHiCodeCategory {
  final HiCodeManagementRepository repository;
  CreateHiCodeCategory(this.repository);

  // PERUBAHAN: Sekarang menerima File, bukan String URL
  Future<void> call({required String name, required File iconFile}) {
    if (name.trim().isEmpty) {
      throw Exception('Nama kategori tidak boleh kosong.');
    }
    return repository.createCategory(name: name, iconFile: iconFile);
  }
}