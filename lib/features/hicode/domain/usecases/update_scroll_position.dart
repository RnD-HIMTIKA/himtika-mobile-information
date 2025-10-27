import 'package:himtika_mobile_information/features/hicode/domain/repositories/hicode_repository.dart';

class UpdateScrollPosition {
  final HiCodeRepository repository;
  UpdateScrollPosition(this.repository);

  Future<void> call(String chapterId, double position, bool hasReachedBottom) {
    if (position < 0) return Future.value();

    return repository.updateScrollPosition(chapterId, position, hasReachedBottom);
  }
}