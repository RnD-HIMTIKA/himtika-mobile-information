import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import '../../repositories/hicode_management_repository.dart';

class GetHiCodeCategories {
  final HiCodeManagementRepository repository;
  GetHiCodeCategories(this.repository);

  Future<List<HiCodeCategory>> call() {
    return repository.getCategories();
  }
}