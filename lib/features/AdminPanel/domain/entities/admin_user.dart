import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';

class AdminUser extends Equatable {
  final String userId;
  final String username;
  final String fullName;
  final List<Role> roles;

  const AdminUser({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.roles,
  });

  @override
  List<Object?> get props => [userId, username, fullName, roles];
}