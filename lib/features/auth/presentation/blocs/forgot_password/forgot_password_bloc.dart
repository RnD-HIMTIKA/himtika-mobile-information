import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../domain/usecases/send_password_reset_otp.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final SendPasswordResetOtp _sendPasswordResetOtp;

  ForgotPasswordBloc({required SendPasswordResetOtp sendPasswordResetOtp})
      : _sendPasswordResetOtp = sendPasswordResetOtp,
        super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    try {
      await _sendPasswordResetOtp(event.email);
      emit(ForgotPasswordSuccess(email: event.email));
    } catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);

      // 2. Pesan Profesional
      // Pesan dari use case (Email tidak terdaftar, Akun Google) sudah user-friendly
      String message = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(ForgotPasswordFailure(message));
    }
  }
}