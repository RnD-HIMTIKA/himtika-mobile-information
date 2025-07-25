import '../../domain/entities/role_permission.dart';
import '../models/role_permission_model.dart';

class RolePermissionMapper {
  static RolePermission toEntity(RolePermissionModel model) {
    return RolePermission(
      roleId: model.roleId,
      permissionId: model.permissionId,
    );
  }

  static RolePermissionModel toModel(RolePermission entity) {
    return RolePermissionModel(
      roleId: entity.roleId,
      permissionId: entity.permissionId,
    );
  }
}