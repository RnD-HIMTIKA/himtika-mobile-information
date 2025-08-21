import '../entities/workspace.dart';

abstract class CalendarRepository {
  Future<List<Workspace>> getMyWorkspaces();
  // (Nantinya kita akan tambahkan metode lain seperti createWorkspace, getEvents, dll.)
}