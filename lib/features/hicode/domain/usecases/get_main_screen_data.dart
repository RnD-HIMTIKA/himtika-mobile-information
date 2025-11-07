import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_material.dart';
import '../repositories/hicode_repository.dart';

class GetMainScreenData {
  final HiCodeRepository repository;
  GetMainScreenData(this.repository);

  Future<(
    List<HiCodeCategory> categories,
    List<HiCodeMaterial> materials,
    bool allMaterialsComplete,
    bool canTakeExamToday,
    DateTime? nextExamAvailableAt
  )> call() {
    return repository.getMainScreenData();
  }
}