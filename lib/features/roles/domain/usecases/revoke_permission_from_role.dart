import '../repositories/roles_repository.dart';

class RevokePermissionFromRole {
  final RolesRepository repository;

  RevokePermissionFromRole(this.repository);

  Future<void> call(String roleId, String permissionId) {
    return repository.revokePermissionFromRole(roleId, permissionId);
  }
}