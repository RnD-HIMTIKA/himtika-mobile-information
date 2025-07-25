import '../../domain/entities/permission.dart';
import '../../domain/usecases/get_user_permissions.dart';
import '../../domain/usecases/get_permissions_by_role.dart';

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
}

class RolesController implements IRolesController {
  final GetUserPermissions getUserPermissions;
  final GetPermissionsByRole getPermissionsByRoleUsecase;

  RolesController({
    required this.getUserPermissions,
    required this.getPermissionsByRoleUsecase,
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
}