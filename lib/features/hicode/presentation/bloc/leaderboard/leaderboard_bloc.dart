import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/leaderboard_entry.dart'; // <-- Import entity baru
import '../../../domain/usecases/get_leaderboard.dart'; // <-- Import use case

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

// Hapus data dummy _allTimeUsers dan _weeklyUsers

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  // Tambahkan dependency GetLeaderboard
  final GetLeaderboard _getLeaderboard;

  // Modifikasi constructor
  LeaderboardBloc({required GetLeaderboard getLeaderboard})
      : _getLeaderboard = getLeaderboard,
        super(const LeaderboardState()) { // State awal tetap
    on<FetchLeaderboard>(_onFetchLeaderboard);
    on<FilterChanged>(_onFilterChanged);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
  }

  // Modifikasi handler FetchLeaderboard
  Future<void> _onFetchLeaderboard(FetchLeaderboard event, Emitter<LeaderboardState> emit) async {
    emit(state.copyWith(status: LeaderboardStatus.loading));
    try {
      final users = await _getLeaderboard('all');
      emit(state.copyWith(
          status: LeaderboardStatus.success,
          users: users,
          selectedFilter: LeaderboardFilter.allTime
      ));
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional (Kode Anda sudah benar)
      String message = "Gagal memuat leaderboard.";
      if (e.toString().toLowerCase().contains('socket')) { // 'socketexception'
        message = "Gagal memuat. Periksa koneksi internet Anda.";
      }
      emit(state.copyWith(status: LeaderboardStatus.failure, errorMessage: message));
    }
  }

  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    final filterString = state.selectedFilter == LeaderboardFilter.allTime ? 'all' : 'weekly';
    emit(state.copyWith(status: LeaderboardStatus.loading, clearError: true));
    try {
      final users = await _getLeaderboard(filterString);
      emit(state.copyWith(
        status: LeaderboardStatus.success,
        users: users,
      ));
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = "Gagal menyegarkan data.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(status: LeaderboardStatus.failure, errorMessage: message));
    }
  }

  Future<void> _onFilterChanged(FilterChanged event, Emitter<LeaderboardState> emit) async {
    final filterString = event.filter == LeaderboardFilter.allTime ? 'all' : 'weekly';
    emit(state.copyWith(status: LeaderboardStatus.loading, selectedFilter: event.filter));
    try {
      final users = await _getLeaderboard(filterString);
      emit(state.copyWith(
          status: LeaderboardStatus.success,
          users: users
      ));
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional (Kode Anda sudah benar)
      String message = "Gagal memuat leaderboard.";
      if (e.toString().toLowerCase().contains('socket')) { // 'socketexception'
        message = "Gagal memuat. Periksa koneksi internet Anda.";
      }
      emit(state.copyWith(status: LeaderboardStatus.failure, errorMessage: message));
    }
  }
}