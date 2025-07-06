import '../repositories/roles_repository.dart';

class AssignRole {
  final RolesRepository repository;

  AssignRole(this.repository);

  Future<void> call(String userId, String roleId) async {
    await repository.assignRole(userId, roleId);
  }
}