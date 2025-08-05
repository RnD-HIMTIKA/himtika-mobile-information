import 'package:equatable/equatable.dart';
import '../../domain/entities/user_with_roles.dart';

abstract class AdminRolesState extends Equatable {
  const AdminRolesState();

  @override
  List<Object> get props => [];
}

class AdminRolesInitial extends AdminRolesState {}

class AdminRolesLoading extends AdminRolesState {}

class AdminRolesLoaded extends AdminRolesState {
  final List<UserWithRoles> users;

  const AdminRolesLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class AdminRolesError extends AdminRolesState {
  final String message;

  const AdminRolesError(this.message);

  @override
  List<Object> get props => [message];
}