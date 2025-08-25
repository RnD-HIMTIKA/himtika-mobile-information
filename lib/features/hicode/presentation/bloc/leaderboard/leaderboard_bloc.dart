import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

final List<Map<String, dynamic>> _allTimeUsers = [
  {'name': 'King Mahes', 'score': '2,569 PTS', 'avatar': 'src/features/hicode/rank/avatar3.png'},
  {'name': 'Auf Kucai', 'score': '1,469 PTS', 'avatar': 'src/features/hicode/rank/avatar2.png'},
  {'name': 'Raika Maulana', 'score': '1,053 PTS', 'avatar': 'src/features/hicode/rank/avatar3.png'},
  {'name': 'Manray Batagor', 'score': '590 points', 'avatar': 'src/features/hicode/rank/avatar1.png'},
  {'name': 'Geral Sayang', 'score': '448 points', 'avatar': 'src/features/hicode/rank/avatar2.png'},
  {'name': 'Geral Sayang', 'score': '448 points', 'avatar': 'src/features/hicode/rank/avatar2.png'},
  {'name': 'Geral Sayang', 'score': '448 points', 'avatar': 'src/features/hicode/rank/avatar2.png'},
  {'name': 'Geral Sayang', 'score': '448 points', 'avatar': 'src/features/hicode/rank/avatar2.png'},
  {'name': 'Geral Sayang', 'score': '448 points', 'avatar': 'src/features/hicode/rank/avatar2.png'},
  {'name': 'Geral Sayang', 'score': '448 points', 'avatar': 'src/features/hicode/rank/avatar2.png'},
];

final List<Map<String, dynamic>> _weeklyUsers = [
  {'name': 'Auf Kucai', 'score': '820 PTS', 'avatar': 'src/features/hicode/rank/avatar1.png'},
  {'name': 'Geral Sayang', 'score': '750 PTS', 'avatar': 'src/features/hicode/rank/avatar2.png'},
  {'name': 'King Mahes', 'score': '610 PTS', 'avatar': 'src/features/hicode/rank/avatar3.png'},
  {'name': 'Raika Maulana', 'score': '400 points', 'avatar': 'src/features/hicode/rank/avatar3.png'},
  {'name': 'Manray Batagor', 'score': '210 points', 'avatar': 'src/features/hicode/rank/avatar1.png'},
  {'name': 'Manray Batagor', 'score': '210 points', 'avatar': 'src/features/hicode/rank/avatar1.png'},
  {'name': 'Manray Batagor', 'score': '210 points', 'avatar': 'src/features/hicode/rank/avatar1.png'},
];


class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc() : super(const LeaderboardState()) {
    on<FetchLeaderboard>(_onFetchLeaderboard);
    on<FilterChanged>(_onFilterChanged);
  }

  void _onFetchLeaderboard(FetchLeaderboard event, Emitter<LeaderboardState> emit) {
    emit(state.copyWith(status: LeaderboardStatus.loading));
    emit(state.copyWith(
        status: LeaderboardStatus.success, users: _allTimeUsers));
  }

  void _onFilterChanged(FilterChanged event, Emitter<LeaderboardState> emit) {
    emit(state.copyWith(status: LeaderboardStatus.loading));
    final usersToShow = event.filter == LeaderboardFilter.allTime ? _allTimeUsers : _weeklyUsers;
    emit(state.copyWith(
        status: LeaderboardStatus.success,
        selectedFilter: event.filter,
        users: usersToShow));
  }
}