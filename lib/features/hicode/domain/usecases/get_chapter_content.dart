import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_chapter_content.dart';
import 'package:himtika_mobile_information/features/hicode/domain/repositories/hicode_repository.dart';

class GetChapterContent {
  final HiCodeRepository repository;
  GetChapterContent(this.repository);

  Future<HiCodeChapterContent> call(String chapterId, String userId) {
    return repository.getChapterContent(chapterId, userId);
  }
}