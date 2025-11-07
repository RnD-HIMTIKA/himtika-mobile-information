import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_material.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/get_main_screen_data.dart';
import 'package:himtika_mobile_information/core/blocs/connectivity_bloc.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart';

part 'main_screen_event.dart';
part 'main_screen_state.dart';

class HicodeBloc extends Bloc<HicodeEvent, HicodeState> {
  final GetMainScreenData _getMainScreenData;
  // 3. Tambahkan ConnectivityBloc dan StreamSubscription
  final ConnectivityBloc _connectivityBloc;
  StreamSubscription? _connectivitySubscription;
  bool _wasOffline = false; // Lacak status sebelumnya

  HicodeBloc({
    required GetMainScreenData getMainScreenData,
    required ConnectivityBloc connectivityBloc, // 4. Tambahkan di constructor
  })  : _getMainScreenData = getMainScreenData,
        _connectivityBloc = connectivityBloc, // 5. Inisialisasi
        super(const HicodeState()) {
    on<HicodeDataFetched>(_onHicodeDataFetched);

    // 6. Mulai mendengarkan
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    // Cek status awal
    if (_connectivityBloc.state.result == ConnectivityResult.none) {
      _wasOffline = true;
    }

    _connectivitySubscription = _connectivityBloc.stream.listen((connectivityState) {
      final isOnline = connectivityState.result != ConnectivityResult.none;

      // Jika status berubah dari OFFLINE ke ONLINE
      if (isOnline && _wasOffline) {
        print("--- [HicodeBloc] Kembali Online, memuat ulang data... ---");
        add(HicodeDataFetched()); // Panggil event refresh
      }
      // Update status terakhir
      _wasOffline = !isOnline;
    });
  }

  // 7. Jangan lupa dispose subscription
  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  Future<void> _onHicodeDataFetched(
      HicodeDataFetched event, Emitter<HicodeState> emit) async {
    // Gunakan state.categories.isEmpty untuk cek data lama
    emit(state.copyWith(
        status: state.categories.isEmpty
            ? HicodeStatus.loading
            : HicodeStatus.success)); // <-- Ubah di sini agar tidak full loading
    try {
      final (categories, materials, allComplete, canTake, nextExamAt) =
          await _getMainScreenData();

      emit(state.copyWith(
        status: HicodeStatus.success,
        categories: categories,
        materials: materials,
        allMaterialsComplete: allComplete,
        canTakeExamToday: canTake,
        nextExamAvailableAt: nextExamAt,
      ));
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = "Gagal memuat data HiCode.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
        status: HicodeStatus.failure,
        errorMessage: message, // <-- Pesan profesional
      ));
    }
  }
}