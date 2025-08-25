import '../entities/admin_dashboard_info.dart';
import '../repositories/admin_panel_repository.dart';

class GetAdminDashboardInfo {
  final AdminPanelRepository repository;

  GetAdminDashboardInfo(this.repository);

  Future<AdminDashboardInfo> call() {
    return repository.getDashboardInfo();
  }
}