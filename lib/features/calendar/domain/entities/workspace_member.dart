import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';

// Entitas ini menggabungkan data User dengan perannya di workspace
class WorkspaceMember extends Equatable {
  final User user;
  final String role; // 'owner', 'editor', atau 'viewer'

  const WorkspaceMember({
    required this.user,
    required this.role,
  });

  @override
  List<Object?> get props => [user, role];
}