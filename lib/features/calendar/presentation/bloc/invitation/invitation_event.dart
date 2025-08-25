part of 'invitation_bloc.dart';

abstract class InvitationEvent extends Equatable {
  const InvitationEvent();
  @override
  List<Object> get props => [];
}

class LoadMyInvitations extends InvitationEvent {}

// Event untuk menerima via ID (dari notifikasi)
class AcceptInvitationByIdPressed extends InvitationEvent {
  final String invitationId;
  const AcceptInvitationByIdPressed(this.invitationId);
  @override
  List<Object> get props => [invitationId];
}

// Event BARU untuk menerima via Token (dari deep link)
class AcceptInvitationByTokenPressed extends InvitationEvent {
  final String token;
  const AcceptInvitationByTokenPressed(this.token);
  @override
  List<Object> get props => [token];
}

class DeclineInvitationPressed extends InvitationEvent {
  final String invitationId;
  const DeclineInvitationPressed(this.invitationId);
  @override
  List<Object> get props => [invitationId];
}