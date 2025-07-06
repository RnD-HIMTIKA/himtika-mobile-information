import '../../domain/entities/user_role.dart';

class UserRoleModel extends UserRole {
  UserRoleModel ({
    required super.userId,
    required super.roleId,
  });

  factory UserRoleModel.fromJson (Map<String, dynamic> json) {
    return UserRoleModel (
      userId: json['userId'] as String,
      roleId: json['roleId'] as String,
    );
  }
}