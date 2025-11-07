import '../../repositories/hicode_management_repository.dart';

class DeleteHiCodeMaterial {
  final HiCodeManagementRepository repository;
  DeleteHiCodeMaterial(this.repository);

  Future<void> call({required String id}) {
    if (id.trim().isEmpty) {
      throw Exception('ID Materi tidak valid.');
    }
    return repository.deleteMaterial(id: id);
  }
}