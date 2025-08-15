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
      // 1. Panggil use case sign in
      await signInWithEmail(event.email, event.password);

      // 2. Panggil use case untuk verifikasi user
      final user = await getCurrentUser();
      if (user != null) {
        emit(LoginSuccess());
      } else {
        emit(const LoginFailure('Login gagal. Periksa kembali email dan password Anda.'));
      }
    } catch (e) {
      // Tangkap error dari use case
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogle event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      // 1. Panggil use case untuk memulai alur OAuth
      await signInWithGoogle();
      
      // 2. Verifikasi (bisa dipindahkan ke use case juga)
      // Untuk saat ini, kita biarkan di sini sebagai bagian dari flow UI
      bool userFound = false;
      for (int i = 0; i < 10; i++) { // Coba selama 5 detik
          await Future.delayed(const Duration(milliseconds: 500));
          final user = await getCurrentUser();
          if (user != null) {
              userFound = true;
              break;
          }
      }

      if (userFound) {
          emit(LoginSuccess());
      } else {
          emit(const LoginFailure('Gagal memverifikasi sesi Google. Silakan coba lagi.'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}