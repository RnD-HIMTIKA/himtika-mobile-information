import '../../domain/entities/admin_dashboard_info.dart';
import '../../domain/repositories/admin_panel_repository.dart';
import '../datasources/admin_panel_remote_datasource.dart';

class AdminPanelRepositoryImpl implements AdminPanelRepository {
  final AdminPanelRemoteDatasource remoteDatasource;

  AdminPanelRepositoryImpl({required this.remoteDatasource});

  @override
  Future<AdminDashboardInfo> getDashboardInfo() async {
    final data = await remoteDatasource.getDashboardInfo();
    return AdminDashboardInfo(
      username: data['username'],
      pengurusRoles: List<String>.from(data['pengurus_roles']),
      profilePictureUrl: data['profile_picture'],
    );
  }
}