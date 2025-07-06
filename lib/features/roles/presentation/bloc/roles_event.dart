part of 'roles_bloc.dart';

abstract class RolesEvent extends Equatable {
  const RolesEvent();

  @override
  List<Object> get props => [];
}

class LoadUserRoles extends RolesEvent {
  final String userId;

  const LoadUserRoles(this.userId);

  @override
  List<Object> get props => [userId];
}

class AssignUserRole extends RolesEvent {
  final String userId;
  final String roleId;

  const AssignUserRole(this.userId, this.roleId);

  @override
  List<Object> get props => [userId, roleId];
}

class RevokeUserRole extends RolesEvent {
  final String userId;
  final String roleId;

  const RevokeUserRole(this.userId, this.roleId);

  @override
  List<Object> get props => [userId, roleId];
}