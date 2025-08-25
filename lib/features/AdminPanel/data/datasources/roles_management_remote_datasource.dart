import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RolesManagementRemoteDatasource {
  Future<List<Map<String, dynamic>>> searchUsers(String query);
  Future<List<Map<String, dynamic>>> getAssignableRoles();
  Future<void> updateUserRoles(String userId, List<String> roleIds);
  Future<Map<String, dynamic>> getAllRolesGrouped();
}

class RolesManagementRemoteDatasourceImpl implements RolesManagementRemoteDatasource {
  final SupabaseClient client;
  RolesManagementRemoteDatasourceImpl({required this.client});

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final data = await client.rpc('search_admin_users', params: {'p_query': query});
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getAssignableRoles() async {
    final data = await client.rpc('get_assignable_roles');
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<void> updateUserRoles(String userId, List<String> roleIds) async {
    await client.rpc('update_user_pengurus_roles', params: {
      'p_user_id': userId,
      'p_role_ids_to_assign': roleIds,
    });
  }

  @override
  Future<Map<String, dynamic>> getAllRolesGrouped() async {
    final data = await client.rpc('get_all_roles_grouped');
    return data as Map<String, dynamic>;
  }
}