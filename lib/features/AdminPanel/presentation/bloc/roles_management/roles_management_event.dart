import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class RolesManagementEvent extends Equatable {
  const RolesManagementEvent();
  @override
  List<Object> get props => [];
}

class SearchUsersChanged extends RolesManagementEvent {
  final String query;
  final String scope;
  const SearchUsersChanged(this.query, {this.scope = 'HIMA'});
  @override
  List<Object> get props => [query, scope];
}

class LoadAllGroupedRoles extends RolesManagementEvent {
  const LoadAllGroupedRoles();
}

class UpdateUserRolesSubmitted extends RolesManagementEvent {
  final String userId;
  final List<String> roleIds;
  final VoidCallback onSuccess; // <-- TAMBAHKAN CALLBACK INI

  const UpdateUserRolesSubmitted(this.userId, this.roleIds, {required this.onSuccess});
  @override
  List<Object> get props => [userId, roleIds];
}

class AssignExclusiveRoleEvent extends RolesManagementEvent {
  final String userId;
  final String roleName;
  const AssignExclusiveRoleEvent({required this.userId, required this.roleName});
  @override
  List<Object> get props => [userId, roleName];
}