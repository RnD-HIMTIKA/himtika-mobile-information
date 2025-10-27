import '../../entities/hicode_chapter.dart';
import '../../repositories/hicode_management_repository.dart';

class GetChaptersByMaterial {
  final HiCodeManagementRepository repository;

  GetChaptersByMaterial(this.repository);

  Future<List<HiCodeChapter>> call(String materialId) {
    return repository.getChaptersByMaterial(materialId);
  }
}