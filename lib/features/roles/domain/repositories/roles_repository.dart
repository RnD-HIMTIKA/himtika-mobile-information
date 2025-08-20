import '../entities/role.dart';
import '../entities/permission.dart';

// Interface ini mendefinisikan kontrak untuk semua operasi terkait roles dan permissions.
abstract class RolesRepository {
  Future<List<Role>> getAllRoles();
  Future<List<Role>> getRolesByUser(String userId);
  Future<void> assignRoleToUser(String userId, String roleId);
  Future<void> revokeRoleFromUser(String userId, String roleId);
  
  Future<List<Permission>> getUserPermissions(String userId);
  Future<List<Permission>> getPermissionsByRole(String roleId);
  Future<void> assignPermissionToRole(String roleId, String permissionId);
  Future<void> revokePermissionFromRole(String roleId, String permissionId);
}