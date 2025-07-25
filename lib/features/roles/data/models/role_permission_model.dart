import '../../domain/entities/role_permission.dart';

class RolePermissionModel {
  final String roleId;
  final String permissionId;

  RolePermissionModel({
    required this.roleId,
    required this.permissionId,
  });

  factory RolePermissionModel.fromJson(Map<String, dynamic> json) {
    return RolePermissionModel(
      roleId: json['role_id'] as String,
      permissionId: json['permission_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'permission_id': permissionId,
    };
  }

  RolePermission toEntity() {
    return RolePermission(
      roleId: roleId,
      permissionId: permissionId,
    );
  }

  factory RolePermissionModel.fromEntity(RolePermission entity) {
    return RolePermissionModel(
      roleId: entity.roleId,
      permissionId: entity.permissionId,
    );
  }
}