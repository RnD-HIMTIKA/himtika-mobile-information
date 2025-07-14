import '../repositories/roles_repository.dart';

class RevokeRole {
  final RolesRepository repository;

  RevokeRole(this.repository);

  Future<void> call (String userId, String roleId) {
    return repository.revokeRole(userId, roleId);
  }
}