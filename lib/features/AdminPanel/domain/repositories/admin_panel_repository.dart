import '../entities/admin_dashboard_info.dart';

abstract class AdminPanelRepository {
  Future<AdminDashboardInfo> getDashboardInfo();
}