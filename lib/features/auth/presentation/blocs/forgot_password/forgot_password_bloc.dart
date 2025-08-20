import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    } catch (e) {
      // Tangkap semua jenis error dari use case dan tampilkan pesannya
      emit(ForgotPasswordFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}