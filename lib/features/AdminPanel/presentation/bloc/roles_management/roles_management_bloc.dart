// AdminPanel/presentation/bloc/roles_management/roles_management_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/get_all_roles_grouped.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/get_assignable_roles.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/search_admin_users.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/update_user_roles.dart';
import '../../../domain/usecases/assign_exclusive_role.dart';
import 'roles_management_event.dart';
import 'roles_management_state.dart';

class RolesManagementBloc
    extends Bloc<RolesManagementEvent, RolesManagementState> {
  final SearchAdminUsers _searchAdminUsers;
  final GetAssignableRoles _getAssignableRoles;
  final UpdateUserRoles _updateUserRoles;
  final GetAllRolesGrouped _getAllRolesGrouped;
  final AssignExclusiveRole _assignExclusiveRole;

  RolesManagementBloc({
    required SearchAdminUsers searchAdminUsers,
    required GetAssignableRoles getAssignableRoles,
    required UpdateUserRoles updateUserRoles,
    required GetAllRolesGrouped getAllRolesGrouped,
    required AssignExclusiveRole assignExclusiveRole,
  })  : _searchAdminUsers = searchAdminUsers,
        _getAssignableRoles = getAssignableRoles,
        _updateUserRoles = updateUserRoles,
        _getAllRolesGrouped = getAllRolesGrouped,
        _assignExclusiveRole = assignExclusiveRole,
        super(const RolesManagementState()) {
    on<SearchUsersChanged>(_onSearchUsersChanged, transformer: restartable());
    on<LoadAllGroupedRoles>(_onLoadAllGroupedRoles);
    on<UpdateUserRolesSubmitted>(_onUpdateUserRolesSubmitted);
    on<AssignExclusiveRoleEvent>(_onAssignExclusiveRole);
  }

  Future<void> _onSearchUsersChanged(
      SearchUsersChanged event, Emitter<RolesManagementState> emit) async {
    emit(state.copyWith(status: RolesManagementStatus.loading));
    try {
      // PERBAIKAN DI SINI
      final users = await _searchAdminUsers(event.query, event.scope);

      // Logika ini bisa disederhanakan
      if (state.assignableRoles.isEmpty) {
        final assignableRoles = await _getAssignableRoles();
        emit(state.copyWith(
          status: RolesManagementStatus.loaded,
          users: users,
          assignableRoles: assignableRoles,
        ));
      } else {
        emit(state.copyWith(
          status: RolesManagementStatus.loaded,
          users: users,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RolesManagementStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadAllGroupedRoles(
      LoadAllGroupedRoles event, Emitter<RolesManagementState> emit) async {
    // Tambahkan loading state agar UI bisa menampilkan progress indicator
    emit(state.copyWith(status: RolesManagementStatus.loading));
    try {
      final groupedRoles = await _getAllRolesGrouped();
      emit(state.copyWith(
        status: RolesManagementStatus.loaded,
        allGroupedRoles: groupedRoles
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RolesManagementStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateUserRolesSubmitted(
      UpdateUserRolesSubmitted event, Emitter<RolesManagementState> emit) async {
    try {
      await _updateUserRoles(event.userId, event.roleIds);
      
      // Panggil callback untuk memicu refresh di UI lain
      event.onSuccess(); 
      
      // Tetap muat ulang data di halaman ini juga
      add(const SearchUsersChanged(''));
    } catch (e) {
      emit(state.copyWith(
        status: RolesManagementStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onAssignExclusiveRole(
    AssignExclusiveRoleEvent event,
    Emitter<RolesManagementState> emit,
  ) async {
    // 1. Ubah status jadi loading (opsional, agar UI bisa nampilin loading jika perlu)
    emit(state.copyWith(status: RolesManagementStatus.loading));

    try {
      // 2. Panggil UseCase (Jembatan ke Server)
      // Kita pakai .call() langsung
      await _assignExclusiveRole.call(event.userId, event.roleName);

      // 3. Jika Sukses (Tidak ada error di atas), 
      // Kita harus Refresh data user agar tampilan berubah otomatis
      // Kita panggil event search ulang (kosongkan query biar reload semua)
      add(const SearchUsersChanged('')); 
      
    } catch (e) {
      // 4. Jika Gagal, kembalikan error message
      emit(state.copyWith(
        status: RolesManagementStatus.failure,
        errorMessage: e.toString(), // Pesan error asli dari Exception
      ));
    }
  }
}