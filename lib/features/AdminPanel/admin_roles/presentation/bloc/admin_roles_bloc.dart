import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_roles_event.dart';
import 'admin_roles_state.dart';
import '../../application/admin_roles_controller.dart';

class AdminRolesBloc extends Bloc<AdminRolesEvent, AdminRolesState> {
  final AdminRolesController controller;

  AdminRolesBloc(this.controller) : super(AdminRolesInitial()) {
    on<LoadUsersWithRoles>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    LoadUsersWithRoles event,
    Emitter<AdminRolesState> emit,
  ) async {
    emit(AdminRolesLoading());

    try {
      final users = await controller.loadUsers();
      emit(AdminRolesLoaded(users));
    } catch (e) {
      emit(AdminRolesError(e.toString()));
    }
  }
}