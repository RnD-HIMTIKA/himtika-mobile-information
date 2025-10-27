import '../../repositories/hicode_management_repository.dart';

class ReorderHiCodeChapters {
  final HiCodeManagementRepository repository;

  ReorderHiCodeChapters(this.repository);

  Future<void> call(String materialId, List<String> chapterIds) {
    if (materialId.trim().isEmpty) {
      throw Exception('Material ID tidak valid.');
    }
    if (chapterIds.isEmpty) {
      throw Exception('Daftar chapter tidak boleh kosong.');
    }
    return repository.reorderChapters(materialId, chapterIds);
  }
}