import '../entities/permission.dart';
import '../repositories/roles_repository.dart';

class GetPermissionsByRole {
  final RolesRepository repository;

  GetPermissionsByRole(this.repository);

  Future<List<Permission>> call(String roleId) {
    return repository.getPermissionsByRole(roleId);
  }
}