import '../entities/admin_user.dart';
import '../repositories/roles_management_repository.dart';

class SearchAdminUsers {
  final RolesManagementRepository repository;
  SearchAdminUsers(this.repository);

  Future<List<AdminUser>> call(String query) {
    return repository.searchUsers(query);
  }
}