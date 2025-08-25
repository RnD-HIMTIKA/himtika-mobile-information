import 'package:equatable/equatable.dart';

// Entitas ini merepresentasikan satu undangan workspace
class Invitation extends Equatable {
  final String id;
  final String workspaceId;
  final String workspaceTitle;
  final String inviterName;
  final String roleToGrant;
  final DateTime createdAt;

  const Invitation({
    required this.id,
    required this.workspaceId,
    required this.workspaceTitle,
    required this.inviterName,
    required this.roleToGrant,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, workspaceId, workspaceTitle, inviterName, roleToGrant, createdAt];
}