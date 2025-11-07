import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/resend_signup_otp.dart';
import '../../../domain/usecases/verify_otp.dart';

part 'otp_event.dart';
part 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final VerifyOtp _verifyOtp;
  final ResendSignUpOtp _resendSignUpOtp;

  OtpBloc({
    required VerifyOtp verifyOtp,
    required ResendSignUpOtp resendSignUpOtp,
  })  : _verifyOtp = verifyOtp,
        _resendSignUpOtp = resendSignUpOtp,
        super(OtpInitial()) {
    on<VerifyOtpButtonPressed>(_onVerifyOtpButtonPressed);
    on<ResendOtpButtonPressed>(_onResendOtpButtonPressed);
  }

  Future<void> _onVerifyOtpButtonPressed(
    VerifyOtpButtonPressed event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpVerificationLoading());
    try {
      await _verifyOtp(email: event.email, token: event.otp);

      // HAPUS STATUS SETELAH VERIFIKASI BERHASIL
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('verification_email');
      
      emit(OtpVerificationSuccess());
    } catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      
      // 2. Pesan Profesional
      String message = "Kode OTP salah atau sudah kedaluwarsa.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(OtpVerificationFailure(message));
    }
  }

  Future<void> _onResendOtpButtonPressed(
    ResendOtpButtonPressed event,
    Emitter<OtpState> emit,
  ) async {
    try {
      await _resendSignUpOtp(email: event.email);
      emit(OtpResendSuccess());
      emit(OtpInitial());
    } catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);

      // 2. Pesan Profesional
      String message = "Gagal mengirim ulang kode. Coba lagi nanti.";
      if (e.toString().toLowerCase().contains('rate limit')) {
        message = "Terlalu banyak percobaan. Coba lagi dalam 60 detik.";
      } else if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(OtpVerificationFailure(message));
    }
  }
}