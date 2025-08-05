import '../../domain/entities/permission.dart';
import '../../domain/entities/role.dart';
import '../../domain/usecases/get_user_permissions.dart';
import '../../domain/usecases/get_permissions_by_role.dart';
import '../../domain/usecases/get_all_roles.dart';
import '../../domain/usecases/get_roles_by_user.dart';

abstract class IRolesController {
  /// Cek apakah user boleh akses fitur tertentu
  Future<bool> can(String userId, String feature, String action);

  /// Cek apakah role tertentu boleh akses fitur tertentu
  Future<bool> canRole(String roleId, String feature, String action);

  /// Ambil semua fitur yg bisa diakses user (dengan permission terdaftar)
  Future<List<String>> getFeatures(String userId);

  /// Ambil semua aksi dari suatu fitur untuk user
  Future<List<String>> getActions(String userId, String feature);

  /// Ambil permission berdasarkan role (untuk validasi UI)
  Future<List<Permission>> getPermissionsByRole(String roleId);

  /// Ambil role yang bisa ditugaskan oleh user tertentu
  Future<List<Role>> getAssignableRoles(String userId);
}

class RolesController implements IRolesController {
  final GetUserPermissions getUserPermissions;
  final GetPermissionsByRole getPermissionsByRoleUsecase;
  final GetAllRoles getAllRoles;
  final GetRolesByUser getRolesByUser;

  RolesController({
    required this.getUserPermissions,
    required this.getPermissionsByRoleUsecase,
    required this.getAllRoles,
    required this.getRolesByUser,
  });

  @override
  Future<bool> can(String userId, String feature, String action) async {
    final permissions = await getUserPermissions(userId);
    return permissions.any((p) => p.key == '$feature:$action');
  }

  @override
  Future<bool> canRole(String roleId, String feature, String action) async {
    final permissions = await getPermissionsByRoleUsecase(roleId);
    return permissions.any((p) => p.key == '$feature:$action');
  }

  @override
  Future<List<String>> getFeatures(String userId) async {
    final permissions = await getUserPermissions(userId);
    return permissions.map((p) => p.featureName).toSet().toList();
  }

  @override
  Future<List<String>> getActions(String userId, String feature) async {
    final permissions = await getUserPermissions(userId);
    return permissions
        .where((p) => p.featureName == feature)
        .map((p) => p.actionName)
        .toList();
  }

  @override
  Future<List<Permission>> getPermissionsByRole(String roleId) async {
    return await getPermissionsByRoleUsecase(roleId);
  }

  @override
  Future<List<Role>> getAssignableRoles(String userId) async {
    final userRoles = await getRolesByUser(userId);
    final allRoles = await getAllRoles(userId);

    final isRnD = userRoles.any((r) => r.name.toLowerCase() == 'rnd');
    if (isRnD) return allRoles;

    final isKahim = userRoles.any((r) => r.name.toLowerCase() == 'kahim');
    if (isKahim) {
      return allRoles.where((r) => r.groupName.toLowerCase() == 'pengurus').toList();
    }

    return []; // Tidak bisa assign role apapun
  }
}