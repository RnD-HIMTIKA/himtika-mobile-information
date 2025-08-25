import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/invitation.dart';
import '../../../domain/usecases/get_my_invitations.dart';
import '../../../domain/usecases/accept_invitation_by_id.dart'; // Perbarui import
import '../../../domain/usecases/accept_invitation_by_token.dart'; // Import baru
import '../../../domain/usecases/decline_invitation.dart';

part 'invitation_event.dart';
part 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final GetMyInvitations _getMyInvitations;
  final AcceptInvitationById _acceptInvitationById;
  final AcceptInvitationByToken _acceptInvitationByToken;
  final DeclineInvitation _declineInvitation;

  InvitationBloc({
    required GetMyInvitations getMyInvitations,
    required AcceptInvitationById acceptInvitationById, // Perbarui tipe
    required AcceptInvitationByToken acceptInvitationByToken,
    required DeclineInvitation declineInvitation,
  })  : _getMyInvitations = getMyInvitations,
        _acceptInvitationById = acceptInvitationById,
        _acceptInvitationByToken = acceptInvitationByToken,
        _declineInvitation = declineInvitation,
        super(const InvitationState()) {
    on<LoadMyInvitations>(_onLoadMyInvitations);
    on<AcceptInvitationByIdPressed>(_onAcceptInvitationById);
    on<AcceptInvitationByTokenPressed>(_onAcceptInvitationByToken);
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

  Future<void> _onAcceptInvitationById(
    AcceptInvitationByIdPressed event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      await _acceptInvitationById(event.invitationId);
      add(LoadMyInvitations());
      emit(state.copyWith(status: InvitationStatus.actionSuccess));
    } catch (e) {
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
  
  Future<void> _onAcceptInvitationByToken(
    AcceptInvitationByTokenPressed event,
    Emitter<InvitationState> emit,
  ) async {
    // Di halaman handler, kita bisa tampilkan loading
    emit(state.copyWith(status: InvitationStatus.loading));
    try {
      await _acceptInvitationByToken(event.token);
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
      add(LoadMyInvitations());
    } catch (e) {
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}