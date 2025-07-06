import '../../domain/entities/permission.dart';
import '../../domain/repositories/roles_repository.dart';
import '../datasources/roles_remote_datasource.dart';
import '../models/permission_model.dart';

class RolesRepositoryImpl implements RolesRepository {
  final RolesRemoteDatasource datasource;

  RolesRepositoryImpl(this.datasource);
  
  Future<List<Permission>> getUserPermissions(String userId) async {
    final raw = await datasource.fetchUserPermissions(userId);
    return raw.map((e) => PermissionModel.fromJson(e)).toList();
  }

  Future<void> assignRole(String userId, String roleId) async {
    await datasource.assignRole(userId, roleId);
  }

  Future<void> revokeRole(String userId, String roleId) async {
    await datasource.revokeRole(userId, roleId);
  }
}