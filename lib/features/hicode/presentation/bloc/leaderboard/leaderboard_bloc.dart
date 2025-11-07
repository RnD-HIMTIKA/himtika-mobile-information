import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:himtika_mobile_information/core/blocs/connectivity_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  final ConnectivityBloc _connectivityBloc;
  StreamSubscription? _connectivitySubscription;
  bool _wasOffline = false;

  // Modifikasi constructor
  LeaderboardBloc({
    required GetLeaderboard getLeaderboard,
    required ConnectivityBloc connectivityBloc,
  })  : _getLeaderboard = getLeaderboard,
        _connectivityBloc = connectivityBloc,
        super(const LeaderboardState()) {
    on<FetchLeaderboard>(_onFetchLeaderboard);
    on<FilterChanged>(_onFilterChanged);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);

    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    if (_connectivityBloc.state.result == ConnectivityResult.none) {
      _wasOffline = true;
    }
    _connectivitySubscription = _connectivityBloc.stream.listen((connectivityState) {
      final isOnline = connectivityState.result != ConnectivityResult.none;
      if (isOnline && _wasOffline) {
        print("--- [LeaderboardBloc] Kembali Online, memuat ulang data... ---");
        // Panggil event refresh yang sesuai dengan filter saat ini
        add(RefreshLeaderboard()); 
      }
      _wasOffline = !isOnline;
    });
  }

  // --- 8. Tambahkan dispose ---
  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
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