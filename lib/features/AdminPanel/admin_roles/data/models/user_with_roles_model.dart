import '../../domain/entities/user_with_roles.dart';
import '../../../../roles/data/models/role_model.dart';

class UserWithRolesModel {
  final String id;
  final String npm;
  final String username;
  final String fullName;
  final List<RoleModel> roles;

  UserWithRolesModel({
    required this.id,
    required this.npm,
    required this.username,
    required this.fullName,
    required this.roles,
  });

  factory UserWithRolesModel.fromJson(Map<String, dynamic> json) {
    return UserWithRolesModel(
      id: json['id'] as String,
      npm: json['npm'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      roles: (json['roles'] as List<dynamic>)
          .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'npm': npm,
        'username': username,
        'full_name': fullName,
        'roles': roles.map((r) => r.toJson()).toList(),
      };

  UserWithRoles toEntity() => UserWithRoles(
        id: id,
        npm: npm,
        username: username,
        fullName: fullName,
        roles: roles.map((r) => r.toEntity()).toList(),
      );
}