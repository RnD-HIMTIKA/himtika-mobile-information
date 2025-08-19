import '../../domain/entities/role.dart';
import '../../domain/entities/permission.dart';
import '../../domain/repositories/roles_repository.dart';
import '../datasources/roles_remote_datasource.dart';

// RepositoryImpl sekarang bertanggung jawab untuk mapping data mentah ke Entity.
class RolesRepositoryImpl implements RolesRepository {
  final RolesRemoteDatasource remoteDatasource;

  RolesRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Role>> getAllRoles() async {
    final data = await remoteDatasource.getAllRoles();
    return data.map((json) => Role(
      id: json['id'],
      name: json['name'],
      groupName: json['group_name'],
    )).toList();
  }

  @override
  Future<List<Role>> getRolesByUser(String userId) async {
    final data = await remoteDatasource.getRolesByUser(userId);
    // Data yang dikembalikan adalah list, di mana setiap elemen punya key 'roles'
    return data.map((item) => Role(
      id: item['roles']['id'],
      name: item['roles']['name'],
      groupName: item['roles']['group_name'],
    )).toList();
  }

  @override
  Future<void> assignRoleToUser(String userId, String roleId) async {
    await remoteDatasource.assignRoleToUser(userId, roleId);
  }

  @override
  Future<void> revokeRoleFromUser(String userId, String roleId) async {
    await remoteDatasource.revokeRoleFromUser(userId, roleId);
  }

  @override
  Future<List<Permission>> getUserPermissions(String userId) async {
    final data = await remoteDatasource.getUserPermissions(userId);
    return data.map((json) => Permission(
      featureName: json['feature_name'],
      actionName: json['action_name'],
    )).toList();
  }

  @override
  Future<List<Permission>> getPermissionsByRole(String roleId) async {
    final data = await remoteDatasource.getPermissionsByRole(roleId);
    return data.map((json) => Permission(
      featureName: json['feature_name'],
      actionName: json['action_name'],
    )).toList();
  }
  
  @override
  Future<void> assignPermissionToRole(String roleId, String permissionId) async {
    await remoteDatasource.assignPermissionToRole(roleId, permissionId);
  }

  @override
  Future<void> revokePermissionFromRole(String roleId, String permissionId) async {
    await remoteDatasource.revokePermissionFromRole(roleId, permissionId);
  }
}