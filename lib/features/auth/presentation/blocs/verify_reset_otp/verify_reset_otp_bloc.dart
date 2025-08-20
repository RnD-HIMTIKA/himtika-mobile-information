import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/verify_password_reset_otp.dart';

part 'verify_reset_otp_event.dart';
part 'verify_reset_otp_state.dart';

class VerifyResetOtpBloc extends Bloc<VerifyResetOtpEvent, VerifyResetOtpState> {
  final VerifyPasswordResetOtp _verifyPasswordResetOtp;

  VerifyResetOtpBloc({required VerifyPasswordResetOtp verifyPasswordResetOtp})
      : _verifyPasswordResetOtp = verifyPasswordResetOtp,
        super(VerifyResetOtpInitial()) {
    on<VerifyResetOtpSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    VerifyResetOtpSubmitted event,
    Emitter<VerifyResetOtpState> emit,
  ) async {
    emit(VerifyResetOtpLoading());
    try {
      // PERBAIKAN DI SINI: Panggil dengan positional arguments
      await _verifyPasswordResetOtp(event.email, event.token);
      emit(VerifyResetOtpSuccess());
    } catch (e) {
      emit(VerifyResetOtpFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}