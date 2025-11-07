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
      // Panggil use case dengan filter awal ('all')
      final users = await _getLeaderboard('all');
      emit(state.copyWith(
          status: LeaderboardStatus.success,
          users: users, // Simpan List<LeaderboardEntry>
          selectedFilter: LeaderboardFilter.allTime // Pastikan filter awal benar
      ));
    } catch (e) {
      // --- PERBAIKAN PESAN ERROR ---
      String message = "Gagal memuat leaderboard.";
      if (e.toString().toLowerCase().contains('socketexception')) {
        message = "Gagal memuat. Periksa koneksi internet Anda.";
      }
      emit(state.copyWith(status: LeaderboardStatus.failure, errorMessage: message));
      // --- AKHIR PERBAIKAN ---
    }
  }

  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    // Tentukan filter string berdasarkan state saat ini
    final filterString = state.selectedFilter == LeaderboardFilter.allTime ? 'all' : 'weekly';
    
    // Emit loading, tapi JANGAN hapus data lama (users)
    emit(state.copyWith(status: LeaderboardStatus.loading, clearError: true));
    try {
      final users = await _getLeaderboard(filterString);
      emit(state.copyWith(
        status: LeaderboardStatus.success,
        users: users,
      ));
    } catch (e) {
      // (Kita akan perbaiki pesan error ini di langkah berikutnya)
      emit(state.copyWith(status: LeaderboardStatus.failure, errorMessage: e.toString()));
    }
  }

  // Modifikasi handler FilterChanged
  Future<void> _onFilterChanged(FilterChanged event, Emitter<LeaderboardState> emit) async {
    // Tentukan string filter berdasarkan enum
    final filterString = event.filter == LeaderboardFilter.allTime ? 'all' : 'weekly';

    emit(state.copyWith(status: LeaderboardStatus.loading, selectedFilter: event.filter)); // Update filter di state
    try {
      // Panggil use case dengan filter yang dipilih
      final users = await _getLeaderboard(filterString);
      emit(state.copyWith(
          status: LeaderboardStatus.success,
          users: users // Simpan data baru
      ));
    } catch (e) {
      // --- PERBAIKAN PESAN ERROR ---
      String message = "Gagal memuat leaderboard.";
      if (e.toString().toLowerCase().contains('socketexception')) {
        message = "Gagal memuat. Periksa koneksi internet Anda.";
      }
      emit(state.copyWith(status: LeaderboardStatus.failure, errorMessage: message));
      // --- AKHIR PERBAIKAN ---
    }
  }
}