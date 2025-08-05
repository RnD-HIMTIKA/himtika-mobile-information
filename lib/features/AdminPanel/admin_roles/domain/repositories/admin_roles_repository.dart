import '../entities/user_with_roles.dart';

abstract class AdminRolesRepository {
  Future<List<UserWithRoles>> getAllUsersWithRoles();
}