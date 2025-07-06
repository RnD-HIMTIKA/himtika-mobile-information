import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/permission.dart';
import '../../domain/usecases/get_user_permissions.dart';
import '../../domain/usecases/assign_role.dart';
import '../../domain/usecases/revoke_role.dart';

part 'roles_event.dart';
part 'roles_state.dart';

class RolesBloc extends Bloc<RolesEvent, RolesState> {
  final GetUserPermissions getUserPermissions;
  final AssignRole assignRole;
  final RevokeRole revokeRole;

  RolesBloc({
    required this.getUserPermissions,
    required this.assignRole,
    required this.revokeRole,
  }) : super(RolesInitial()) {
    on<LoadUserRoles>(_onLoadUserRoles);
    on<AssignUserRole>(_onAssignUserRole);
    on<RevokeUserRole>(_onRevokeUserRole);
  }

  Future<void> _onLoadUserRoles(LoadUserRoles event, Emitter<RolesState> emit) async {
    emit(RolesLoading());
    try {
      final permissions = await getUserPermissions(event.userId);
      emit(RolesLoaded(permissions: permissions));
    } catch (e) {
      emit(RolesError(message: e.toString()));
    }
  }

  Future<void> _onAssignUserRole(AssignUserRole event, Emitter<RolesState> emit) async {
    try {
      await assignRole(event.userId, event.roleId);
      add(LoadUserRoles(event.userId)); // reload permissions
    } catch (e) {
      emit(RolesError(message: e.toString()));
    }
  }

  Future<void> _onRevokeUserRole(RevokeUserRole event, Emitter<RolesState> emit) async {
    try {
      await revokeRole(event.userId, event.roleId);
      add(LoadUserRoles(event.userId)); // reload permissions
    } catch (e) {
      emit(RolesError(message: e.toString()));
    }
  }
}