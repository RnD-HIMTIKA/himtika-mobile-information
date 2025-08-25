import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';
import '../repositories/roles_management_repository.dart';

class GetAllRolesGrouped {
  final RolesManagementRepository repository;
  GetAllRolesGrouped(this.repository);

  Future<Map<String, List<Role>>> call() {
    return repository.getAllRolesGrouped();
  }
}