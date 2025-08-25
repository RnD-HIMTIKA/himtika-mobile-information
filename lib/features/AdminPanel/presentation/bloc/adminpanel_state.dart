import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_dashboard_info.dart';
import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';

abstract class AdminPanelState extends Equatable {
  const AdminPanelState();

  @override
  List<Object?> get props => [];
}

class AdminPanelInitial extends AdminPanelState {}

class AdminPanelLoading extends AdminPanelState {}

class AdminPanelLoaded extends AdminPanelState {
  final AdminDashboardInfo dashboardInfo;
  final List<Role> currentUserRoles; // <-- TAMBAHKAN INI

  const AdminPanelLoaded({
    required this.dashboardInfo,
    required this.currentUserRoles, // <-- TAMBAHKAN INI
  });

  @override
  List<Object?> get props => [dashboardInfo, currentUserRoles];
}

class AdminPanelFailure extends AdminPanelState {
  final String message;

  const AdminPanelFailure({required this.message});

  @override
  List<Object?> get props => [message];
}