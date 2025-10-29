import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final int rank;
  final String userId;
  final String username;
  final String fullName;
  final String? profileUrl;
  final int highestScore;
  final int? fastestTimeSeconds; // Nullable jika waktu tidak relevan (misal skor 0)
  final DateTime? lastExamTimestamp; // Nullable jika belum pernah ujian

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.fullName,
    this.profileUrl,
    required this.highestScore,
    this.fastestTimeSeconds,
    this.lastExamTimestamp,
  });

  @override
  List<Object?> get props => [
        rank,
        userId,
        username,
        fullName,
        profileUrl,
        highestScore,
        fastestTimeSeconds,
        lastExamTimestamp,
      ];
}