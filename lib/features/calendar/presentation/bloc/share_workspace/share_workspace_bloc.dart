import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/invite_user_to_workspace.dart';

part 'share_workspace_event.dart';
part 'share_workspace_state.dart';

class ShareWorkspaceBloc extends Bloc<ShareWorkspaceEvent, ShareWorkspaceState> {
  final InviteUserToWorkspace _inviteUserToWorkspace;

  ShareWorkspaceBloc({required InviteUserToWorkspace inviteUserToWorkspace})
      : _inviteUserToWorkspace = inviteUserToWorkspace,
        super(const ShareWorkspaceState()) {
    on<InviteUserSubmitted>(_onInviteUserSubmitted);
  }

  Future<void> _onInviteUserSubmitted(
    InviteUserSubmitted event,
    Emitter<ShareWorkspaceState> emit,
  ) async {
    emit(state.copyWith(status: ShareStatus.loading));
    try {
      await _inviteUserToWorkspace(
        workspaceId: event.workspaceId,
        inviteeEmail: event.email,
        role: event.role,
      );
      emit(state.copyWith(status: ShareStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ShareStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}