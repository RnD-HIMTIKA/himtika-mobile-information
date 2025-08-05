import '../entities/user_with_roles.dart';
import '../repositories/admin_roles_repository.dart';

class GetAllUsersWithRoles {
  final AdminRolesRepository repository;

  GetAllUsersWithRoles(this.repository);

  Future<List<UserWithRoles>> execute() async {
    return await repository.getAllUsersWithRoles();
  }
}