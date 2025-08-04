import 'package:himtika_mobile_information/features/roles/application/roles_controller/roles_controller.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_user_permissions.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_permissions_by_role.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_all_roles.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_roles_by_user.dart';

class AppService {
  static late final RolesController rolesController;

  static void init({
    required GetUserPermissions getUserPermissions,
    required GetPermissionsByRole getPermissionsByRole,
    required GetAllRoles getAllRoles,
    required GetRolesByUser getRolesByUser,
  }) {
    rolesController = RolesController(
      getUserPermissions: getUserPermissions,
      getPermissionsByRoleUsecase: getPermissionsByRole,
      getAllRoles: getAllRoles,
      getRolesByUser: getRolesByUser,
    );
  }
}