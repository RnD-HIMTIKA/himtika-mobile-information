class RolePermissionModel {
  final String roleId;
  final String permissionId;

  RolePermissionModel({
    required this.roleId,
    required this.permissionId,
  });

  factory RolePermissionModel.fromMap(Map<String, dynamic> map) {
    return RolePermissionModel(
      roleId: map['role_Id'] as String,
      permissionId: map['permission_Id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role_Id': roleId,
      'permission_Id': permissionId,
    };
  }
}