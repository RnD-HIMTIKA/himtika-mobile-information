part of 'leaderboard_bloc.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();
  @override
  List<Object> get props => [];
}

// Event untuk mengambil data awal
class FetchLeaderboard extends LeaderboardEvent {}

class RefreshLeaderboard extends LeaderboardEvent {}

// Event saat filter diubah (All Time / Weekly)
class FilterChanged extends LeaderboardEvent {
  final LeaderboardFilter filter;
  const FilterChanged({required this.filter});
}