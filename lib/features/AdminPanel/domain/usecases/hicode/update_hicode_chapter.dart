import '../../repositories/hicode_management_repository.dart';

class UpdateHiCodeChapter {
  final HiCodeManagementRepository repository;

  UpdateHiCodeChapter(this.repository);

  Future<void> call({
    required String id,
    String? title,
    List<dynamic>? content,
    int? estimatedReadTime,
    int? order,
    bool? isQuizless,
  }) {
    if (id.trim().isEmpty) {
      throw Exception('ID Chapter tidak valid.');
    }
    if (title != null && title.trim().isEmpty) {
      throw Exception('Judul chapter tidak boleh kosong.');
    }
    if (content != null && content.isEmpty) {
      throw Exception('Konten chapter tidak boleh kosong.');
    }
    return repository.updateChapter(
      id: id,
      title: title,
      content: content,
      estimatedReadTime: estimatedReadTime,
      order: order,
      isQuizless: isQuizless,
    );
  }
}