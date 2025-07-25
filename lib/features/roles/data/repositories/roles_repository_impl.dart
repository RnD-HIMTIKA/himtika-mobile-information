import '../../domain/entities/role.dart';
import '../../domain/entities/permission.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/role_permission.dart';
import '../../domain/repositories/roles_repository.dart';
import '../datasources/roles_remote_datasource.dart';
import '../mappers/role_mapper.dart';
import '../mappers/permission_mapper.dart';
import '../mappers/user_role_mapper.dart';
import '../mappers/role_permission_mapper.dart';

class RolesRepositoryImpl implements RolesRepository {
  final RolesRemoteDatasource remoteDatasource;

  RolesRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Role>> getAllRoles(String userId) async {
    final models = await remoteDatasource.getAllRoles(userId);
    return models.map(RoleMapper.toEntity).toList();
  }

  @override
  Future<void> assignRole(String userId, String roleId) async {
    await remoteDatasource.assignRole(userId, roleId);
  }

  @override
  Future<void> revokeRole(String userId, String roleId) async {
    await remoteDatasource.revokeRole(userId, roleId);
  }

  @override
  Future<List<Permission>> getUserPermissions(String userId) async {
    final models = await remoteDatasource.getUserPermissions(userId);
    return models.map(PermissionMapper.toEntity).toList();
  }

  @override
  Future<List<UserRole>> getUserRoles(String userId) async {
    final models = await remoteDatasource.getUserRoles(userId);
    return models.map(UserRoleMapper.toEntity).toList();
  }

  @override
  Future<void> assignPermissionToRole(String roleId, String permissionId) async {
    await remoteDatasource.assignPermissionToRole(roleId, permissionId);
  }

  @override
  Future<void> revokePermissionFromRole(String roleId, String permissionId) async {
    await remoteDatasource.revokePermissionFromRole(roleId, permissionId);
  }

  @override
  Future<List<RolePermission>> getPermissionsByRoleId(String roleId) async {
    final models = await remoteDatasource.getPermissionsByRoleId(roleId);
    return models.map(RolePermissionMapper.toEntity).toList();
  }

  @override
  Future<List<Permission>> getPermissionsByRole(String roleId) async {
    final models = await remoteDatasource.getPermissionsByRole(roleId);
    return models.map(PermissionMapper.toEntity).toList();
  }
}