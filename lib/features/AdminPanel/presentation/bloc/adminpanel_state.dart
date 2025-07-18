import 'package:equatable/equatable.dart';

abstract class AdminPanelState extends Equatable {
  const AdminPanelState();

  @override
  List<Object?> get props => [];
}

class AdminPanelInitial extends AdminPanelState {}

class AdminPanelLoaded extends AdminPanelState {
  final String userName;
  final String userRole;

  const AdminPanelLoaded({required this.userName, required this.userRole});

  @override
  List<Object?> get props => [userName, userRole];
}
