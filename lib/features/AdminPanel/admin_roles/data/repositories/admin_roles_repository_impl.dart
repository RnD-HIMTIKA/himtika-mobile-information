import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_with_roles.dart';
import '../../domain/repositories/admin_roles_repository.dart';
import '../models/user_with_roles_model.dart';

class AdminRolesRepositoryImpl implements AdminRolesRepository {
  final SupabaseClient client;

  AdminRolesRepositoryImpl(this.client);

  @override
  Future<List<UserWithRoles>> getAllUsersWithRoles() async {
    final response = await client.rpc('get_all_users_with_roles').execute();

    if (response.data == null) {
      throw Exception('Failed to fetch users: No data');
    }

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((item) => UserWithRolesModel.fromJson(item).toEntity())
        .toList();
  }
}