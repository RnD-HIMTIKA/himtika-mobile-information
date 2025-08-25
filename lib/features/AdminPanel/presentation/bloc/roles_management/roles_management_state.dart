import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_user.dart';
import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';

enum RolesManagementStatus { initial, loading, loaded, failure }

class RolesManagementState extends Equatable {
  final RolesManagementStatus status;
  final List<AdminUser> users;
  final List<Role> assignableRoles; // Untuk HIMA Roles
  final Map<String, List<Role>> allGroupedRoles; // <-- TAMBAHKAN INI (Untuk General Roles)
  final String? errorMessage;

  const RolesManagementState({
    this.status = RolesManagementStatus.initial,
    this.users = const [],
    this.assignableRoles = const [],
    this.allGroupedRoles = const {}, // <-- TAMBAHKAN INI
    this.errorMessage,
  });

  RolesManagementState copyWith({
    RolesManagementStatus? status,
    List<AdminUser>? users,
    List<Role>? assignableRoles,
    Map<String, List<Role>>? allGroupedRoles, // <-- TAMBAHKAN INI
    String? errorMessage,
  }) {
    return RolesManagementState(
      status: status ?? this.status,
      users: users ?? this.users,
      assignableRoles: assignableRoles ?? this.assignableRoles,
      allGroupedRoles: allGroupedRoles ?? this.allGroupedRoles, // <-- TAMBAHKAN INI
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, assignableRoles, allGroupedRoles, errorMessage];
}