import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';
import '../entities/workspace_with_members.dart';
import '../entities/event.dart';
import '../entities/invitation.dart';

abstract class CalendarRepository {
  Future<void> createWorkspace({required String title, required String description});
  Future<List<WorkspaceWithMembers>> getMyWorkspacesWithMembers();
  Future<List<Event>> getEvents(String workspaceId);
  Future<void> createEvent({
    required String workspaceId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  });
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String eventId);
  Future<void> updateWorkspace({required String workspaceId, required String title, required String description});
  Future<void> deleteWorkspace(String workspaceId);
  Future<void> inviteUserToWorkspace({
    required String workspaceId,
    required String inviteeEmail,
    required String role,
  });
  Future<List<Invitation>> getMyInvitations();
  Future<void> acceptInvitation(String invitationId);
  Future<void> declineInvitation(String invitationId);
  Future<List<User>> searchUsers(String query);
  Future<String> createInvitationLink({required String workspaceId, required String role});
  Future<void> inviteByRole({
    required String workspaceId,
    required List<String> targetRoleIds,
    required String roleToGrant,
  });
}