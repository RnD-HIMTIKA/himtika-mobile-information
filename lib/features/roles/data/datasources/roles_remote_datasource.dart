import 'package:supabase_flutter/supabase_flutter.dart';

class RolesRemoteDatasource {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchUserPermissions(String userId) async {
    final data = await _client
        .rpc('get_user_permissions', params: {'user_id': userId});
    if (data == null) throw Exception("Permission not found");
    return List<Map<String, dynamic>>.from(data);
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