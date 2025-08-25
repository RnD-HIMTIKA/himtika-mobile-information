part of 'invitation_bloc.dart';

enum InvitationStatus { initial, loading, loaded, failure, actionSuccess }

class InvitationState extends Equatable {
  final InvitationStatus status;
  final List<Invitation> invitations;
  final String? errorMessage;

  const InvitationState({
    this.status = InvitationStatus.initial,
    this.invitations = const [],
    this.errorMessage,
  });

  InvitationState copyWith({
    InvitationStatus? status,
    List<Invitation>? invitations,
    String? errorMessage,
  }) {
    return InvitationState(
      status: status ?? this.status,
      invitations: invitations ?? this.invitations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, invitations, errorMessage];
}