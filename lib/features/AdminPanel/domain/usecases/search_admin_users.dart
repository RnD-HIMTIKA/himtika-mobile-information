import '../entities/admin_user.dart';
import '../repositories/roles_management_repository.dart';

class SearchAdminUsers {
  final RolesManagementRepository repository;
  SearchAdminUsers(this.repository);

  Future<List<AdminUser>> call(String query, String scope) {
    return repository.searchUsers(query, scope);
  }
}