import '../entities/role.dart';
import '../entities/permission.dart';
import '../entities/user_role.dart';
import '../entities/role_permission.dart';

abstract class RolesRepository {
  Future<List<Role>> getAllRoles(String userId);
  Future<void> assignRole(String userId, String roleId);
  Future<void> revokeRole(String userId, String roleId);
  Future<List<Permission>> getUserPermissions(String userId);
  Future<List<UserRole>> getUserRoles(String userId);
  Future<void> assignPermissionToRole(String roleId, String permissionId);
  Future<void> revokePermissionFromRole(String roleId, String permissionId);
  Future<List<RolePermission>> getPermissionsByRoleId(String roleId);
  Future<List<Permission>> getPermissionsByRole(String roleId);
}