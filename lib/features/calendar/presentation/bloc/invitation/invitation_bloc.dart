import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:himtika_mobile_information/core/blocs/connectivity_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/invitation.dart';
import '../../../domain/usecases/get_my_invitations.dart';
import '../../../domain/usecases/accept_invitation_by_id.dart'; // Perbarui import
import '../../../domain/usecases/accept_invitation_by_token.dart'; // Import baru
import '../../../domain/usecases/decline_invitation.dart';

part 'invitation_event.dart';
part 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final GetMyInvitations _getMyInvitations;
  final AcceptInvitationById _acceptInvitationById;
  final AcceptInvitationByToken _acceptInvitationByToken;
  final DeclineInvitation _declineInvitation;

  final ConnectivityBloc _connectivityBloc;
  StreamSubscription? _connectivitySubscription;
  bool _wasOffline = false;

  InvitationBloc({
    required GetMyInvitations getMyInvitations,
    required AcceptInvitationById acceptInvitationById, // Perbarui tipe
    required AcceptInvitationByToken acceptInvitationByToken,
    required DeclineInvitation declineInvitation,
    required ConnectivityBloc connectivityBloc,
  })  : _getMyInvitations = getMyInvitations,
        _acceptInvitationById = acceptInvitationById,
        _acceptInvitationByToken = acceptInvitationByToken,
        _declineInvitation = declineInvitation,
        _connectivityBloc = connectivityBloc,
        super(const InvitationState()) {
    on<LoadMyInvitations>(_onLoadMyInvitations);
    on<AcceptInvitationByIdPressed>(_onAcceptInvitationById);
    on<AcceptInvitationByTokenPressed>(_onAcceptInvitationByToken);
    on<DeclineInvitationPressed>(_onDeclineInvitation);

    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    if (_connectivityBloc.state.result == ConnectivityResult.none) {
      _wasOffline = true;
    }
    _connectivitySubscription = _connectivityBloc.stream.listen((connectivityState) {
      final isOnline = connectivityState.result != ConnectivityResult.none;
      if (isOnline && _wasOffline) {
        print("--- [InvitationBloc] Kembali Online, memuat ulang undangan... ---");
        add(LoadMyInvitations()); // Panggil event refresh
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

  Future<void> _onLoadMyInvitations(
    LoadMyInvitations event,
    Emitter<InvitationState> emit,
  ) async {
    emit(state.copyWith(status: InvitationStatus.loading));
    try {
      final invitations = await _getMyInvitations();
      emit(state.copyWith(
        status: InvitationStatus.loaded,
        invitations: invitations,
      ));
    } catch (e, stackTrace) { 
      Sentry.captureException(e, stackTrace: stackTrace);
      String message = "Gagal memuat undangan.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: message,
      ));
    }
  }

  Future<void> _onAcceptInvitationById(
    AcceptInvitationByIdPressed event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      await _acceptInvitationById(event.invitationId);
      add(LoadMyInvitations());
      emit(state.copyWith(status: InvitationStatus.actionSuccess));
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = "Gagal menerima undangan. Coba lagi nanti.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: message,
      ));
    }
  }
  
  Future<void> _onAcceptInvitationByToken(
    AcceptInvitationByTokenPressed event,
    Emitter<InvitationState> emit,
  ) async {
    emit(state.copyWith(status: InvitationStatus.loading));
    try {
      await _acceptInvitationByToken(event.token);
      emit(state.copyWith(status: InvitationStatus.actionSuccess));
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = "Gagal bergabung. Link mungkin tidak valid atau kedaluwarsa.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: message,
      ));
    }
  }

  Future<void> _onDeclineInvitation(
    DeclineInvitationPressed event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      await _declineInvitation(event.invitationId);
      add(LoadMyInvitations());
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = "Gagal menolak undangan.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: message,
      ));
    }
  }
}