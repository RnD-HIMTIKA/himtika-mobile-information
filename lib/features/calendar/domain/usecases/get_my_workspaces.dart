import '../entities/workspace.dart';
import '../repositories/calendar_repository.dart';

class GetMyWorkspaces {
  final CalendarRepository repository;

  GetMyWorkspaces(this.repository);

  // Use case ini tidak memerlukan parameter karena akan mengambil workspace
  // untuk pengguna yang sedang login.
  Future<List<Workspace>> call() async {
    return await repository.getMyWorkspaces();
  }
}