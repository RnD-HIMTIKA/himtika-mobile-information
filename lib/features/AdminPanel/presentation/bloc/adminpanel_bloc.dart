import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/get_admin_dashboard_info.dart';
import 'adminpanel_event.dart';
import 'adminpanel_state.dart';

class AdminPanelBloc extends Bloc<AdminPanelEvent, AdminPanelState> {
  final GetAdminDashboardInfo _getAdminDashboardInfo;

  AdminPanelBloc({required GetAdminDashboardInfo getAdminDashboardInfo})
      : _getAdminDashboardInfo = getAdminDashboardInfo,
        super(AdminPanelInitial()) {
    on<LoadAdminPanel>(_onLoadAdminPanel);
  }

  Future<void> _onLoadAdminPanel(
      LoadAdminPanel event, Emitter<AdminPanelState> emit) async {
    emit(AdminPanelLoading());
    try {
      final dashboardInfo = await _getAdminDashboardInfo();
      emit(AdminPanelLoaded(dashboardInfo: dashboardInfo));
    } catch (e) {
      emit(AdminPanelFailure(message: e.toString()));
    }
  }
}