part of 'invitation_bloc.dart';

abstract class InvitationEvent extends Equatable {
  const InvitationEvent();
  @override
  List<Object> get props => [];
}

// Event untuk memuat semua undangan yang tertunda
class LoadMyInvitations extends InvitationEvent {}

// Event saat pengguna menekan tombol "Terima"
class AcceptInvitationPressed extends InvitationEvent {
  final String invitationId;
  const AcceptInvitationPressed(this.invitationId);
  @override
  List<Object> get props => [invitationId];
}

// Event saat pengguna menekan tombol "Tolak"
class DeclineInvitationPressed extends InvitationEvent {
  final String invitationId;
  const DeclineInvitationPressed(this.invitationId);
  @override
  List<Object> get props => [invitationId];
}