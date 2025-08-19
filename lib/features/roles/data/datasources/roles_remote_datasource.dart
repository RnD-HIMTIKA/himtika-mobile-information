import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/helpers/supabase_table_helper.dart';

// Datasource sekarang hanya berinteraksi dengan Supabase dan mengembalikan data mentah (List<Map>).
class RolesRemoteDatasource {
  Future<List<Map<String, dynamic>>> getAllRoles() async {
    return await SupabaseTableHelper.table('roles').select();
  }

  Future<List<Map<String, dynamic>>> getRolesByUser(String userId) async {
    return await SupabaseTableHelper.table('user_roles')
        .select('roles(*)')
        .eq('user_id', userId);
  }

  Future<void> assignRoleToUser(String userId, String roleId) async {
    await SupabaseTableHelper.table('user_roles').insert({
      'user_id': userId,
      'role_id': roleId,
    });
  }

  Future<void> revokeRoleFromUser(String userId, String roleId) async {
    await SupabaseTableHelper.table('user_roles')
        .delete()
        .match({'user_id': userId, 'role_id': roleId});
  }
  
  // Fungsi RPC tetap sama karena sudah efisien.
  Future<List<Map<String, dynamic>>> getUserPermissions(String userId) async {
    final data = await Supabase.instance.client
        .rpc('get_user_permissions', params: {'p_user_id': userId});
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getPermissionsByRole(String roleId) async {
    final data = await Supabase.instance.client.rpc(
      'get_permissions_by_role',
      params: {'p_role_id': roleId},
    );
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<void> assignPermissionToRole(String roleId, String permissionId) async {
    await SupabaseTableHelper.table('role_permissions').insert({
      'role_id': roleId,
      'permission_id': permissionId,
    });
  }

  Future<void> revokePermissionFromRole(String roleId, String permissionId) async {
    await SupabaseTableHelper.table('role_permissions')
        .delete()
        .match({'role_id': roleId, 'permission_id': permissionId});
  }
}