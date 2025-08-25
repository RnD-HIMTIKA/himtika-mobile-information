import '../repositories/calendar_repository.dart';

class InviteUserToWorkspace {
  final CalendarRepository repository;

  InviteUserToWorkspace(this.repository);

  Future<void> call({
    required String workspaceId,
    required String inviteeEmail,
    required String role,
  }) async {
    if (inviteeEmail.trim().isEmpty || !inviteeEmail.contains('@')) {
      throw Exception('Format email tidak valid.');
    }
    return await repository.inviteUserToWorkspace(
      workspaceId: workspaceId,
      inviteeEmail: inviteeEmail,
      role: role,
    );
  }
}