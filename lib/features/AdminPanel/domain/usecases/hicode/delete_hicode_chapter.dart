import '../../repositories/hicode_management_repository.dart';

class DeleteHiCodeChapter {
  final HiCodeManagementRepository repository;

  DeleteHiCodeChapter(this.repository);

  Future<void> call({required String id}) {
    if (id.trim().isEmpty) {
      throw Exception('ID Chapter tidak valid.');
    }
    return repository.deleteChapter(id);
  }
}