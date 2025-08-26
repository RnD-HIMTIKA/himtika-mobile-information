import '../../repositories/hicode_management_repository.dart';

class DeleteHiCodeCategory {
  final HiCodeManagementRepository repository;
  DeleteHiCodeCategory(this.repository);

  Future<void> call({required String id}) {
    if (id.trim().isEmpty) {
      throw Exception('ID Kategori tidak valid.');
    }
    return repository.deleteCategory(id: id);
  }
}