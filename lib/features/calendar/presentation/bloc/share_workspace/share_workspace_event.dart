part of 'share_workspace_bloc.dart';

abstract class ShareWorkspaceEvent extends Equatable {
  const ShareWorkspaceEvent();
  @override
  List<Object> get props => [];
}

// Event saat teks di search bar berubah
class SearchUserChanged extends ShareWorkspaceEvent {
  final String query;
  const SearchUserChanged(this.query);
  @override
  List<Object> get props => [query];
}

// Event untuk membersihkan hasil pencarian
class ClearSearch extends ShareWorkspaceEvent {
  const ClearSearch();
}

// Event saat pengguna menekan tombol "Invite"
class InviteUserSubmitted extends ShareWorkspaceEvent {
  final String workspaceId;
  final String email;
  final String role;

  const InviteUserSubmitted({
    required this.workspaceId,
    required this.email,
    required this.role,
  });
  @override
  List<Object> get props => [workspaceId, email, role];
}

// Event untuk membuat dan menyalin link undangan
class CreateAndCopyInvitationLink extends ShareWorkspaceEvent {
  final String workspaceId;
  final String role;
  const CreateAndCopyInvitationLink({required this.workspaceId, required this.role});
  @override
  List<Object> get props => [workspaceId, role];
}

// Event saat pengguna menekan "Simpan" di dialog "Bagikan ke Role"
class InviteByRoleSubmitted extends ShareWorkspaceEvent {
  final String workspaceId;
  final List<Role> targetRoles;
  final String roleToGrant;

  const InviteByRoleSubmitted({
    required this.workspaceId,
    required this.targetRoles,
    required this.roleToGrant,
  });

  @override
  List<Object> get props => [workspaceId, targetRoles, roleToGrant];
}