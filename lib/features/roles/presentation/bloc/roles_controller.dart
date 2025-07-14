import '../../domain/usecases/get_user_permissions.dart';

class RolesController {
  final GetUserPermissions getUserPermissions;

  RolesController(this.getUserPermissions);

  Future<bool> can(String userId, String feature, String action) async {
    final permissions = await getUserPermissions(userId);
    return permissions.any((p) => p.key == '$feature.$action');
  }

  Future<List<String>> getFeatures(String userId) async {
    final permissions = await getUserPermissions(userId);
    return permissions.map((p) => p.featureName).toSet().toList();
  }

  Future<List<String>> getActions(String userId, String feature) async {
    final permissions = await getUserPermissions(userId);
    return permissions
        .where((p) => p.featureName == feature)
        .map((p) => p.actionName)
        .toList();
  }
}