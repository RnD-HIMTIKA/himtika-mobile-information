import 'package:equatable/equatable.dart';

abstract class RolesManagementEvent extends Equatable {
  const RolesManagementEvent();
  @override
  List<Object> get props => [];
}

class SearchUsersChanged extends RolesManagementEvent {
  final String query;
  const SearchUsersChanged(this.query);
  @override
  List<Object> get props => [query];
}

// TAMBAHKAN EVENT BARU DI SINI
class LoadAllGroupedRoles extends RolesManagementEvent {
  const LoadAllGroupedRoles();
}

class UpdateUserRolesSubmitted extends RolesManagementEvent {
  final String userId;
  final List<String> roleIds;
  const UpdateUserRolesSubmitted(this.userId, this.roleIds);
  @override
  List<Object> get props => [userId, roleIds];
}