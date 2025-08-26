import 'dart:io';
import '../../repositories/hicode_management_repository.dart';

class UpdateHiCodeCategory {
  final HiCodeManagementRepository repository;
  UpdateHiCodeCategory(this.repository);

  // PERUBAHAN: Menerima File opsional. Jika null, ikon tidak diubah.
  Future<void> call({required String id, required String name, File? iconFile}) {
     if (id.trim().isEmpty || name.trim().isEmpty) {
      throw Exception('ID dan Nama tidak boleh kosong.');
    }
    return repository.updateCategory(id: id, name: name, iconFile: iconFile);
  }
}