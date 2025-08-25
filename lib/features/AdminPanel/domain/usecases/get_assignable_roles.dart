import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';
import '../repositories/roles_management_repository.dart';

class GetAssignableRoles {
  final RolesManagementRepository repository;
  GetAssignableRoles(this.repository);

  Future<List<Role>> call() {
    return repository.getAssignableRoles();
  }
}