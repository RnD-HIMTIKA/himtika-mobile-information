part of 'roles_bloc.dart';

abstract class RolesState extends Equatable {
  const RolesState();

  @override
  List<Object> get props => [];
}

class RolesInitial extends RolesState {}

class RolesLoading extends RolesState {}

class RolesLoaded extends RolesState {
  final List<Permission> permissions;

  const RolesLoaded({required this.permissions});

  @override
  List<Object> get props => [permissions];
}

class RolesError extends RolesState {
  final String message;

  const RolesError({required this.message});

  @override
  List<Object> get props => [message];
}