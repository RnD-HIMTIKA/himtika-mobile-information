import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/invitation.dart';
import '../../../domain/usecases/get_my_invitations.dart';
import '../../../domain/usecases/accept_invitation.dart';
import '../../../domain/usecases/decline_invitation.dart';

part 'invitation_event.dart';
part 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final GetMyInvitations _getMyInvitations;
  final AcceptInvitation _acceptInvitation;
  final DeclineInvitation _declineInvitation;

  InvitationBloc({
    required GetMyInvitations getMyInvitations,
    required AcceptInvitation acceptInvitation,
    required DeclineInvitation declineInvitation,
  })  : _getMyInvitations = getMyInvitations,
        _acceptInvitation = acceptInvitation,
        _declineInvitation = declineInvitation,
        super(const InvitationState()) {
    on<LoadMyInvitations>(_onLoadMyInvitations);
    on<AcceptInvitationPressed>(_onAcceptInvitation);
    on<DeclineInvitationPressed>(_onDeclineInvitation);
  }

  Future<void> _onLoadMyInvitations(
    LoadMyInvitations event,
    Emitter<InvitationState> emit,
  ) async {
    emit(state.copyWith(status: InvitationStatus.loading));
    try {
      final invitations = await _getMyInvitations();
      emit(state.copyWith(
        status: InvitationStatus.loaded,
        invitations: invitations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAcceptInvitation(
    AcceptInvitationPressed event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      // PERBAIKAN: Gunakan nama properti yang benar, yaitu 'invitationId'
      await _acceptInvitation(event.invitationId);
      add(LoadMyInvitations()); // Muat ulang daftar setelah aksi
      emit(state.copyWith(status: InvitationStatus.actionSuccess));
    } catch (e) {
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeclineInvitation(
    DeclineInvitationPressed event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      await _declineInvitation(event.invitationId);
      add(LoadMyInvitations()); // Muat ulang daftar setelah aksi
    } catch (e) {
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}