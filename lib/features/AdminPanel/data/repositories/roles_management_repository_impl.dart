import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_user.dart';
import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/roles_management_repository.dart';
import '../datasources/roles_management_remote_datasource.dart';

class RolesManagementRepositoryImpl implements RolesManagementRepository {
  final RolesManagementRemoteDatasource remoteDatasource;
  RolesManagementRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<AdminUser>> searchUsers(String query) async {
    final data = await remoteDatasource.searchUsers(query);
    return data.map((item) {
      final rolesData = (item['roles'] as List<dynamic>?) ?? [];
      final roles = rolesData.map((roleMap) => Role(
        id: roleMap['id'],
        name: roleMap['name'],
        groupName: '', // groupName tidak dikirim dari RPC ini, bisa dikosongkan
      )).toList();

      return AdminUser(
        userId: item['user_id'],
        username: item['username'],
        fullName: item['full_name'],
        roles: roles,
      );
    }).toList();
  }

  @override
  Future<List<Role>> getAssignableRoles() async {
    final data = await remoteDatasource.getAssignableRoles();
    return data.map((item) => Role(
      id: item['id'],
      name: item['name'],
      groupName: item['group_name'],
    )).toList();
  }

  @override
  Future<void> updateUserRoles(String userId, List<String> roleIds) {
    return remoteDatasource.updateUserRoles(userId, roleIds);
  }

  @override
  Future<Map<String, List<Role>>> getAllRolesGrouped() async {
    final data = await remoteDatasource.getAllRolesGrouped();
    
    return data.map((key, value) {
      final rolesList = (value as List<dynamic>)
          .map((roleMap) => Role(
                id: roleMap['id'],
                name: roleMap['name'],
                groupName: key,
              ))
          .toList();
      return MapEntry(key, rolesList);
    });
  }
}