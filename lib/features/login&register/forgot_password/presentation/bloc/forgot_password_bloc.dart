import 'package:flutter_bloc/flutter_bloc.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());

    try {
      // Simulasi API request (ganti dengan call ke repository atau API sebenarnya)
      await Future.delayed(const Duration(seconds: 2));

      // Validasi sederhana (bisa kamu ganti dengan logika dari backend)
      if (event.email.isEmpty || !event.email.contains('@')) {
        emit(const ForgotPasswordFailure('Invalid email address.'));
        return;
      }

      // Jika berhasil
      emit(ForgotPasswordSuccess());
    } catch (e) {
      emit(ForgotPasswordFailure('Something went wrong. Please try again.'));
    }
  }
}
