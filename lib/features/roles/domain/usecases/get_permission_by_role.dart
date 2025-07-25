import '../entities/role_permission.dart';
import '../repositories/roles_repository.dart';

class GetPermissionByRole {
  final RolesRepository repository;
  
  GetPermissionByRole(this.repository);

  Future<List<RolePermission>> call(String roleId) async {
    return await repository.getPermissionsByRoleId(roleId);
  }
}