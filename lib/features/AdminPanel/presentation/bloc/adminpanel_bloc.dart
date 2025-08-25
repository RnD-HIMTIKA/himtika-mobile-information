import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/get_admin_dashboard_info.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_my_roles.dart'; // <-- IMPORT
import 'adminpanel_event.dart';
import 'adminpanel_state.dart';

class AdminPanelBloc extends Bloc<AdminPanelEvent, AdminPanelState> {
  final GetAdminDashboardInfo _getAdminDashboardInfo;
  final GetMyRoles _getMyRoles; // <-- TAMBAHKAN

  AdminPanelBloc({
    required GetAdminDashboardInfo getAdminDashboardInfo,
    required GetMyRoles getMyRoles, // <-- TAMBAHKAN
  })  : _getAdminDashboardInfo = getAdminDashboardInfo,
        _getMyRoles = getMyRoles, // <-- TAMBAHKAN
        super(AdminPanelInitial()) {
    on<LoadAdminPanel>(_onLoadAdminPanel);
  }

  Future<void> _onLoadAdminPanel(
      LoadAdminPanel event, Emitter<AdminPanelState> emit) async {
    emit(AdminPanelLoading());
    try {
      final dashboardInfo = await _getAdminDashboardInfo();
      final roles = await _getMyRoles(); // <-- PANGGIL USE CASE
      emit(AdminPanelLoaded(dashboardInfo: dashboardInfo, currentUserRoles: roles));
    } catch (e) {
      emit(AdminPanelFailure(message: e.toString()));
    }
  }
}