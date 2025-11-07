import 'package:flutter_bloc/flutter_bloc.dart';
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
      
    } on AuthException catch (e) { // <-- Tangkap AuthException
      // --- PERBAIKAN PESAN ERROR (Alert 3, 4) ---
      print("AuthException: ${e.message}");
      if (e.message.toLowerCase().contains('email rate limit exceeded')) {
        emit(const RegistrationFailure("Terlalu banyak percobaan. Silakan coba lagi nanti."));
      } else if (e.message.toLowerCase().contains('invalid email')) {
         emit(const RegistrationFailure("Format email tidak valid."));
      } else if (e.message.toLowerCase().contains('user already registered')) {
         emit(const RegistrationFailure("Email ini sudah terdaftar. Silakan login."));
      } else {
        // Fallback untuk error auth lainnya
        emit(RegistrationFailure("Gagal mendaftar: ${e.message}"));
      }
    } catch (e) {
      // --- PERBAIKAN PESAN ERROR (Alert 2) ---
      // Ini akan menangkap error "Exception: Email ini sudah terdaftar." dari use case kita
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(RegistrationFailure(errorMessage));
    }
  }
}