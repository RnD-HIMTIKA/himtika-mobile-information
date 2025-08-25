import 'package:equatable/equatable.dart';

class AdminDashboardInfo extends Equatable {
  final String username;
  final List<String> pengurusRoles;
  final String? profilePictureUrl;

  const AdminDashboardInfo({
    required this.username,
    required this.pengurusRoles,
    this.profilePictureUrl,
  });

  @override
  List<Object?> get props => [username, pengurusRoles, profilePictureUrl];
}