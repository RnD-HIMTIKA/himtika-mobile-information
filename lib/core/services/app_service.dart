import 'package:himtika_mobile_information/features/roles/application/roles_controller/roles_controller.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_user_permissions.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_permissions_by_role.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_all_roles.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_roles_by_user.dart';

import 'package:himtika_mobile_information/features/AdminPanel/admin_roles/application/admin_roles_controller.dart';
import 'package:himtika_mobile_information/features/AdminPanel/admin_roles/domain/usecases/get_all_users_with_roles.dart';

class AppService {
  // ✅ Roles
  static late final RolesController rolesController;

  // ✅ Admin Roles
  static AdminRolesController? _adminRolesController;

  // 🔧 Init untuk RolesController (tetap seperti sebelumnya)
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

  // 🔧 Tambahan init khusus untuk AdminRolesController
  static void initAdminRoles({
    required GetAllUsersWithRoles getAllUsersWithRoles,
  }) {
    _adminRolesController = AdminRolesController(
      getAllUsersWithRoles: getAllUsersWithRoles,
    );
  }

  // Getter
  static AdminRolesController get adminRolesController {
    if (_adminRolesController == null) {
      throw Exception('AdminRolesController belum diinisialisasi! Panggil AppService.initAdminRoles() dulu.');
    }
    return _adminRolesController!;
  }
}