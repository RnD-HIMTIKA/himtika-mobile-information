import '../../../../roles/domain/entities/role.dart';

class UserWithRoles {
  final String id;
  final String npm;
  final String username;
  final String fullName;
  final List<Role> roles;

  UserWithRoles({
    required this.id,
    required this.npm,
    required this.username,
    required this.fullName,
    required this.roles,
  });
}