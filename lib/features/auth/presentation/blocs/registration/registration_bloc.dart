import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/usecases/sign_up_with_email.dart';

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final SignUpWithEmail _signUpWithEmail;

  RegistrationBloc({required SignUpWithEmail signUpWithEmail})
      : _signUpWithEmail = signUpWithEmail,
        super(RegistrationInitial()) {
    on<SignUpButtonPressed>(_onSignUpButtonPressed);
  }

  Future<void> _onSignUpButtonPressed(
    SignUpButtonPressed event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());
    try {
      // --- VALIDASI TAMBAHAN DI SINI (Alert 2) ---
      if (event.password.length < 6) {
        emit(const RegistrationFailure("Password terlalu lemah. Harap gunakan minimal 6 karakter."));
        return;
      }
      // --- AKHIR VALIDASI ---

      await _signUpWithEmail(event.email, event.password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('verification_email', event.email);
      
      emit(RegistrationSuccess(email: event.email));
      
    } on AuthException catch (e, stackTrace) { // Tangkap stackTrace
      // 1. Log Licik (ke Sentry)
      Sentry.captureException(e, stackTrace: stackTrace);
      
      // 2. Pesan Profesional
      String userMessage;
      if (e.message.toLowerCase().contains('email rate limit exceeded')) {
        userMessage = "Terlalu banyak percobaan. Silakan coba lagi nanti.";
      } else if (e.message.toLowerCase().contains('invalid email')) {
         userMessage = "Format email tidak valid.";
      } else if (e.message.toLowerCase().contains('user already registered')) {
         userMessage = "Email ini sudah terdaftar. Silakan login.";
      } else {
        userMessage = "Gagal mendaftar. Coba lagi nanti."; // Pesan umum
      }
      emit(RegistrationFailure(userMessage));

    } catch (e, stackTrace) { // Tangkap semua error lain
      // 1. Log Licik (ke Sentry)
      Sentry.captureException(e, stackTrace: stackTrace);

      // 2. Pesan Profesional
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().toLowerCase().contains('socket')) {
        errorMessage = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(RegistrationFailure(errorMessage));
    }
  }
}