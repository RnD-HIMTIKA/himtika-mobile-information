import '../repositories/roles_repository.dart';
import '../entities/permission.dart';

class GetUserPermissions {
  final RolesRepository repository;

  GetUserPermissions(this.repository);

  Future<List<Permission>> call(String userId) {
    return repository.getUserPermissions(userId);
  }
}