import 'package:equatable/equatable.dart';

abstract class AdminRolesEvent extends Equatable {
  const AdminRolesEvent();

  @override
  List<Object> get props => [];
}

class LoadUsersWithRoles extends AdminRolesEvent {}