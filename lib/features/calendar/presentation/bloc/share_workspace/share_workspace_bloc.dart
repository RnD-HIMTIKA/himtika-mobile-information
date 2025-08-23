import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';
import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';
import '../../../domain/usecases/invite_by_role.dart';
import '../../../domain/usecases/create_invitation_link.dart';
import '../../../domain/usecases/invite_user_to_workspace.dart';
import '../../../domain/usecases/search_users.dart';

part 'share_workspace_event.dart';
part 'share_workspace_state.dart';

class ShareWorkspaceBloc extends Bloc<ShareWorkspaceEvent, ShareWorkspaceState> {
  final InviteUserToWorkspace _inviteUserToWorkspace;
  final SearchUsers _searchUsers;
  final CreateInvitationLink _createInvitationLink;
  final InviteByRole _inviteByRole;
  Timer? _debounce;

  ShareWorkspaceBloc({
    required InviteUserToWorkspace inviteUserToWorkspace,
    required SearchUsers searchUsers,
    required CreateInvitationLink createInvitationLink,
    required InviteByRole inviteByRole,
  })  : _inviteUserToWorkspace = inviteUserToWorkspace,
        _searchUsers = searchUsers,
        _createInvitationLink = createInvitationLink,
        _inviteByRole = inviteByRole,
        super(const ShareWorkspaceState()) {
    on<SearchUserChanged>(
      _onSearchUserChanged,
      // Terapkan transformer debounce di sini
      transformer: droppable(),
    );
    on<InviteUserSubmitted>(_onInviteUserSubmitted, transformer: droppable());
    on<CreateAndCopyInvitationLink>(_onCreateAndCopyLink, transformer: droppable());
    on<ClearSearch>(_onClearSearch);
    on<InviteByRoleSubmitted>(_onInviteByRoleSubmitted, transformer: droppable());
  }

  Future<void> _onSearchUserChanged(
    SearchUserChanged event,
    Emitter<ShareWorkspaceState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      return add(const ClearSearch());
    }
    emit(state.copyWith(searchStatus: SearchStatus.loading));
    try {
      final users = await _searchUsers(event.query);
      emit(state.copyWith(searchStatus: SearchStatus.loaded, searchResults: users));
    } catch (e) {
      emit(state.copyWith(searchStatus: SearchStatus.failure, searchErrorMessage: e.toString()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<ShareWorkspaceState> emit) {
    emit(state.copyWith(searchResults: [], searchStatus: SearchStatus.initial));
  }

  Future<void> _onInviteUserSubmitted(
      InviteUserSubmitted event, Emitter<ShareWorkspaceState> emit) async {
    emit(state.copyWith(shareStatus: ShareStatus.loading, clearShareError: true));
    try {
      await _inviteUserToWorkspace(
        workspaceId: event.workspaceId,
        inviteeEmail: event.email,
        role: event.role,
      );
      emit(state.copyWith(shareStatus: ShareStatus.success));
    } catch (e) {
      emit(state.copyWith(
        shareStatus: ShareStatus.failure,
        shareErrorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
    // Kembalikan status ke initial agar loading hilang
    emit(state.copyWith(shareStatus: ShareStatus.initial));
  }

  Future<void> _onCreateAndCopyLink(
      CreateAndCopyInvitationLink event, Emitter<ShareWorkspaceState> emit) async {
    emit(state.copyWith(shareStatus: ShareStatus.loading, clearShareError: true));
    try {
      final token = await _createInvitationLink(
        workspaceId: event.workspaceId,
        role: event.role,
      );
      final link = 'https://himtika.cs.unsika.ac.id/join-workspace?token=$token';
      await Clipboard.setData(ClipboardData(text: link));
      emit(state.copyWith(shareStatus: ShareStatus.success));
    } catch (e) {
      emit(state.copyWith(
        shareStatus: ShareStatus.failure,
        shareErrorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
    emit(state.copyWith(shareStatus: ShareStatus.initial));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  // Handler untuk undangan berbasis role
  Future<void> _onInviteByRoleSubmitted(
    InviteByRoleSubmitted event,
    Emitter<ShareWorkspaceState> emit,
  ) async {
    emit(state.copyWith(shareStatus: ShareStatus.loading, clearShareError: true));
    try {
      await _inviteByRole(
        workspaceId: event.workspaceId,
        targetRoles: event.targetRoles,
        roleToGrant: event.roleToGrant,
      );
      emit(state.copyWith(shareStatus: ShareStatus.success));
    } catch (e) {
      emit(state.copyWith(
        shareStatus: ShareStatus.failure,
        shareErrorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
    emit(state.copyWith(shareStatus: ShareStatus.initial));
  }
}