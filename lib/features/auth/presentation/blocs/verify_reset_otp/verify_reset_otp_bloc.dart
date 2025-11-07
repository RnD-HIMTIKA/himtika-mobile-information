import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../domain/usecases/verify_password_reset_otp.dart';

part 'verify_reset_otp_event.dart';
part 'verify_reset_otp_state.dart';

class VerifyResetOtpBloc extends Bloc<VerifyResetOtpEvent, VerifyResetOtpState> {
  final VerifyPasswordResetOtp _verifyPasswordResetOtp;

  VerifyResetOtpBloc({required VerifyPasswordResetOtp verifyPasswordResetOtp})
      : _verifyPasswordResetOtp = verifyPasswordResetOtp,
        super(VerifyResetOtpInitial()) {
    on<VerifyResetOtpSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    VerifyResetOtpSubmitted event,
    Emitter<VerifyResetOtpState> emit,
  ) async {
    emit(VerifyResetOtpLoading());
    try {
      await _verifyPasswordResetOtp(event.email, event.token);
      emit(VerifyResetOtpSuccess());
    } catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);

      // 2. Pesan Profesional
      String message = "Kode OTP salah atau sudah kedaluwarsa.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(VerifyResetOtpFailure(message));
    }
  }
}