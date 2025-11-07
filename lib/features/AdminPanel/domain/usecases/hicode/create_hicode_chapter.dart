import '../../repositories/hicode_management_repository.dart';

class CreateHiCodeChapter {
  final HiCodeManagementRepository repository;

  CreateHiCodeChapter(this.repository);

  Future<void> call({
    required String materialId,
    required String title,
    required List<dynamic> content,
    int? estimatedReadTime,
    required int order,
  }) {
    if (title.trim().isEmpty) {
      throw Exception('Judul chapter tidak boleh kosong.');
    }
    if (content.isEmpty) {
      throw Exception('Konten chapter tidak boleh kosong.');
    }
    return repository.createChapter(
      materialId: materialId,
      title: title,
      content: content,
      estimatedReadTime: estimatedReadTime,
      order: order,
    );
  }
}