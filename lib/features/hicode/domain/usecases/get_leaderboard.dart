import '../entities/leaderboard_entry.dart';
import '../repositories/hicode_repository.dart';

class GetLeaderboard {
  final HiCodeRepository repository;

  GetLeaderboard(this.repository);

  // Menerima filter ('all' atau 'weekly')
  Future<List<LeaderboardEntry>> call(String filter) async {
    if (filter != 'all' && filter != 'weekly') {
      throw Exception("Filter tidak valid. Gunakan 'all' atau 'weekly'.");
    }
    return await repository.getLeaderboard(filter);
  }
}