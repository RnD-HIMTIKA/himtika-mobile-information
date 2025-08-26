import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';
import '../entities/admin_user.dart';

abstract class RolesManagementRepository {
  Future<List<AdminUser>> searchUsers(String query, String scope);
  Future<List<Role>> getAssignableRoles();
  Future<void> updateUserRoles(String userId, List<String> roleIds);
  Future<Map<String, List<Role>>> getAllRolesGrouped();
}