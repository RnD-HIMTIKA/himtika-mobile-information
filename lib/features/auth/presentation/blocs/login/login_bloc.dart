// features/auth/presentation/blocs/login/login_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../../domain/usecases/sign_in_with_email.dart';
import '../../../domain/usecases/sign_in_with_google.dart';
import '../../../domain/usecases/get_current_user.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInWithEmail signInWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final GetCurrentUser getCurrentUser;

  LoginBloc({
    required this.signInWithEmail,
    required this.signInWithGoogle,
    required this.getCurrentUser,
  }) : super(const LoginInitial()) {
    on<LoginWithEmail>(_onLoginWithEmail);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoadRememberMeData>(_onLoadRememberMeData);
  }

  Future<void> _onLoginWithEmail(LoginWithEmail event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      await signInWithEmail(event.email, event.password);
      final user = await getCurrentUser();

      if (user != null) {
        // Simpan atau hapus kredensial berdasarkan pilihan "Remember Me"
        final prefs = await SharedPreferences.getInstance();
        if (event.rememberMe) {
          await prefs.setString('email', event.email);
          await prefs.setString('password', event.password);
          await prefs.setBool('rememberMe', true);
        } else {
          await prefs.remove('email');
          await prefs.remove('password');
          await prefs.setBool('rememberMe', false);
        }
        emit(LoginSuccess());
      } else {
        // Ini tidak akan pernah tercapai jika signInWithEmail throw error, tapi sebagai fallback
        emit(const LoginFailure('Login gagal. Terjadi kesalahan tidak diketahui.'));
      }
    } on AuthException catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      
      // 2. Pesan Profesional
      String message;
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        message = 'Email atau Password salah.';
      } else if (e.message.toLowerCase().contains('socket')) {
          message = "Koneksi gagal. Periksa internet Anda.";
      } else {
        message = "Terjadi kesalahan. Coba lagi nanti.";
      }
      emit(LoginFailure(message));

    } catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      
      // 2. Pesan Profesional
      String message = "Terjadi kesalahan. Coba lagi nanti.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(LoginFailure(message));
    }
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogle event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      await signInWithGoogle();
    } catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      
      // 2. Pesan Profesional
      String message = "Gagal login dengan Google. Coba lagi nanti.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(LoginFailure(message));
    }
  }

  Future<void> _onLoadRememberMeData(LoadRememberMeData event, Emitter<LoginState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe && email != null && password != null) {
      emit(LoginInitial(email: email, password: password, rememberMe: rememberMe));
    }
  }
}