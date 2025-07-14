import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/role_model.dart';
import '../models/user_role_model.dart';
import '../models/permission_model.dart';

class RolesRemoteDatasource {
  final _client = Supabase.instance.client;

  Future<List<RoleModel>> getAllRoles(String userId) async {
    final data = await _client
        .from('roles')
        .select()
        .match({'user_id': userId});
    return (data as List)
        .map((json) => RoleModel.fromJson(json))
        .toList();
  }

  Future<List<PermissionModel>> getUserPermissions(String userId) async {
    final data = await _client
        .rpc('get_user_permissions', params: {'user_id': userId});
    if(data == null) throw Exception('No permissions found for user $userId');

    return List<Map<String, dynamic>>.from(data)
        .map((json) => PermissionModel.fromJson(json))
        .toList();
  }

  Future<List<UserRoleModel>> getUserRoles(String userId) async {
    final data = await _client
        .from('user_roles')
        .select()
        .match({'user_id': userId});
    return (data as List)
        .map((json) => UserRoleModel.fromJson(json))
        .toList();
  }
  
  Future<void> assignRole(String userId, String roleId) async {
    await _client.from('user_roles').insert({
      'user_id': userId,
      'role_id': roleId,
    });
  }

  Future<void> revokeRole(String userId, String roleId) async {
    await _client
        .from('user_roles')
        .delete()
        .match({'user_id': userId, 'role_id': roleId});
  }
}