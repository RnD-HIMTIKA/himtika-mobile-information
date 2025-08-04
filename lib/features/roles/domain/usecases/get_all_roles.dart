import '../entities/role.dart';
import '../repositories/roles_repository.dart';

class GetAllRoles {
  final RolesRepository repository;

  GetAllRoles(this.repository);

  Future<List<Role>> call(String userId) async {
    return await repository.getAllRoles(userId);
  }
}