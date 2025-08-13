// features/auth/presentation/blocs/login/login_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
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
  }) : super(LoginInitial()) {
    on<LoginWithEmail>(_onLoginWithEmail);
    on<LoginWithGoogle>(_onLoginWithGoogle);
  }

  Future<void> _onLoginWithEmail(LoginWithEmail event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      // lakukan sign-in (kita tidak bergantung pada struktur AuthResponse)
      await signInWithEmail(event.email, event.password);

      // verifikasi via getCurrentUser() yang sudah menangani mapping public.users
      final user = await getCurrentUser();
      if (user != null) {
        emit(LoginSuccess());
      } else {
        // Bisa disesuaikan pesan; ini menangani kasus login gagal / email belum terverifikasi
        emit(const LoginFailure('Login gagal — cek email & password atau verifikasi email Anda.'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogle event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      // trigger OAuth flow (redirect). Usecase membuka intent/browser.
      await signInWithGoogle();

      // Polling singkat untuk menunggu Supabase mengisi session setelah redirect
      final int maxAttempts = 12; // coba selama ~6 detik (12 * 500ms)
      final Duration delayBetween = const Duration(milliseconds: 500);
      bool found = false;

      for (int i = 0; i < maxAttempts; i++) {
        final user = await getCurrentUser();
        if (user != null) {
          found = true;
          break;
        }
        await Future.delayed(delayBetween);
      }

      if (found) {
        emit(LoginSuccess());
      } else {
        emit(const LoginFailure(
            'Selesaikan proses Google sign-in (cek browser/intent). Jika sudah, tutup dan coba lagi.'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}