import '../repositories/roles_management_repository.dart';

class UpdateUserRoles {
  final RolesManagementRepository repository;
  UpdateUserRoles(this.repository);

  Future<void> call(String userId, List<String> roleIds) {
    return repository.updateUserRoles(userId, roleIds);
  }
}