part of 'leaderboard_bloc.dart';

// Enum untuk status loading dan filter
enum LeaderboardStatus { initial, loading, success, failure }
enum LeaderboardFilter { allTime, weekly }

class LeaderboardState extends Equatable {
  const LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.selectedFilter = LeaderboardFilter.allTime,
    this.users = const [],
  });

  final LeaderboardStatus status;
  final LeaderboardFilter selectedFilter;
  final List<Map<String, dynamic>> users;

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    LeaderboardFilter? selectedFilter,
    List<Map<String, dynamic>>? users,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      users: users ?? this.users,
    );
  }

  @override
  List<Object> get props => [status, selectedFilter, users];
}