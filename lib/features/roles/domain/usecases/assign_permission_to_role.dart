import '../repositories/roles_repository.dart';

class AssignPermissionToRole {
  final RolesRepository repository;

  AssignPermissionToRole(this.repository);

  Future<void> call(String roleId, String permissionId) {
    return repository.assignPermissionToRole(roleId, permissionId);
  }
}