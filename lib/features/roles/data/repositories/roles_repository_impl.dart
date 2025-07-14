import '../../domain/entities/role.dart';
import '../../domain/entities/permission.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/roles_repository.dart';
import '../datasources/roles_remote_datasource.dart';
import '../mappers/role_mapper.dart';
import '../mappers/permission_mapper.dart';
import '../mappers/user_role_mapper.dart';

class RolesRepositoryImpl implements RolesRepository {
  final RolesRemoteDatasource remoteDatasource;

  RolesRepositoryImpl(this.remoteDatasource);
  
  @override
  Future<List<Role>> getAllRoles(String userId) async {
    final roleModels = await remoteDatasource.getAllRoles(userId);
    return roleModels.map((model) => RoleMapper.toEntity(model)).toList();
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
    final permissionModels = await remoteDatasource.getUserPermissions(userId);
    return permissionModels.map((model) => PermissionMapper.toEntity(model)).toList();
  }

  @override
  Future<List<UserRole>> getUserRoles(String userId) async {
    final userRoleModels = await remoteDatasource.getUserRoles(userId);
    return userRoleModels.map((model) => UserRoleMapper.toEntity(model)).toList();
  }
}