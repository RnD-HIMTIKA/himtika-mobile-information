part of 'leaderboard_bloc.dart';

enum LeaderboardStatus { initial, loading, success, failure }
enum LeaderboardFilter { allTime, weekly }

class LeaderboardState extends Equatable {
  const LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.selectedFilter = LeaderboardFilter.allTime,
    this.users = const [],
    this.errorMessage, // <-- Tambahkan errorMessage
  });

  final LeaderboardStatus status;
  final LeaderboardFilter selectedFilter;
  // Ganti tipe data users
  final List<LeaderboardEntry> users;
  final String? errorMessage; // <-- Tambahkan errorMessage

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    LeaderboardFilter? selectedFilter,
    List<LeaderboardEntry>? users,
    String? errorMessage, // <-- Tambahkan errorMessage
    bool clearError = false, // <-- Helper opsional
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      users: users ?? this.users,
      // Tambahkan logic errorMessage
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  // Update props
  List<Object?> get props => [status, selectedFilter, users, errorMessage];
}