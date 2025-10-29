import '../../domain/entities/leaderboard_entry.dart';

class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.rank,
    required super.userId,
    required super.username,
    required super.fullName,
    super.profileUrl,
    required super.highestScore,
    super.fastestTimeSeconds,
    super.lastExamTimestamp,
  });

  factory LeaderboardEntryModel.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntryModel(
      // Konversi rank dari bigint (String di JSON) ke int
      rank: int.tryParse(map['rank']?.toString() ?? '0') ?? 0,
      userId: map['user_id'],
      username: map['username'],
      fullName: map['full_name'],
      profileUrl: map['profile_url'], // Ambil URL profil gabungan
      highestScore: map['highest_score'] ?? 0,
      fastestTimeSeconds: map['fastest_time_seconds'],
      lastExamTimestamp: map['last_exam_timestamp'] != null
          ? DateTime.parse(map['last_exam_timestamp'])
          : null,
    );
  }
}