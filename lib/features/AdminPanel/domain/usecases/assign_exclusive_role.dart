import '../repositories/roles_management_repository.dart';

class AssignExclusiveRole {
  final RolesManagementRepository repository;

  AssignExclusiveRole(this.repository);

  // Fungsi 'call' agar bisa dipanggil langsung
  Future<void> call(String userId, String roleName) async {
    return await repository.assignExclusiveRole(userId, roleName);
  }
}