import '../domain/entities/user_with_roles.dart';
import '../domain/usecases/get_all_users_with_roles.dart';

class AdminRolesController {
  final GetAllUsersWithRoles getAllUsersWithRoles;

  AdminRolesController({
    required this.getAllUsersWithRoles,
  });

  Future<List<UserWithRoles>> loadUsers() async {
    return await getAllUsersWithRoles.execute();
  }
}