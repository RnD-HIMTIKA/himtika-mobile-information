import '../entities/role.dart';
import '../repositories/roles_repository.dart';

class GetRolesByUser {
  final RolesRepository repository;

  GetRolesByUser(this.repository);

  Future<List<Role>> call(String userId) {
    return repository.getRolesByUser(userId);
  }
}