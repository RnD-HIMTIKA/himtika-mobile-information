import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../../../domain/usecases/update_user_password.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final UpdateUserPassword _updateUserPassword;

  ResetPasswordBloc({required UpdateUserPassword updateUserPassword})
      : _updateUserPassword = updateUserPassword,
        super(ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(ResetPasswordLoading());
    try {
      await _updateUserPassword(
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      emit(ResetPasswordSuccess());
    } on AuthException catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      
      // 2. Pesan Profesional
      String message;
      if (e.message.toLowerCase().contains('same password')) {
        message = 'Password baru tidak boleh sama dengan password lama.';
      } else if (e.message.toLowerCase().contains('socket')) {
          message = "Koneksi gagal. Periksa internet Anda.";
      } else {
        message = "Terjadi kesalahan. Coba lagi nanti.";
      }
      emit(ResetPasswordFailure(message));

    } catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      
      // 2. Pesan Profesional
      // Pesan dari use case (Password minimal 6 karakter, Konfirmasi tidak cocok) sudah user-friendly
      String message = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(ResetPasswordFailure(message));
    }
  }
}