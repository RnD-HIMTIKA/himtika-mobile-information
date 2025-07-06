import '../entities/permission.dart';

abstract class RolesRepository {
  Future<List<Permission>> getUserPermissions(String userId);
  Future<void> assignRole(String userId, String roleId);
  Future<void> revokeRole(String userId, String roleId);
}