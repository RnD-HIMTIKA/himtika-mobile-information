import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/resend_signup_otp.dart';
import '../../../domain/usecases/verify_otp.dart';

part 'otp_event.dart';
part 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final VerifyOtp _verifyOtp;
  final ResendSignUpOtp _resendSignUpOtp;

  OtpBloc({
    required VerifyOtp verifyOtp,
    required ResendSignUpOtp resendSignUpOtp,
  })  : _verifyOtp = verifyOtp,
        _resendSignUpOtp = resendSignUpOtp,
        super(OtpInitial()) {
    on<VerifyOtpButtonPressed>(_onVerifyOtpButtonPressed);
    on<ResendOtpButtonPressed>(_onResendOtpButtonPressed);
  }

  Future<void> _onVerifyOtpButtonPressed(
    VerifyOtpButtonPressed event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpVerificationLoading());
    try {
      await _verifyOtp(email: event.email, token: event.otp);

      // HAPUS STATUS SETELAH VERIFIKASI BERHASIL
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('verification_email');
      
      emit(OtpVerificationSuccess());
    } catch (e) {
      emit(OtpVerificationFailure(e.toString()));
    }
  }

  Future<void> _onResendOtpButtonPressed(
    ResendOtpButtonPressed event,
    Emitter<OtpState> emit,
  ) async {
    try {
      await _resendSignUpOtp(email: event.email);
      // Emit state sukses untuk menampilkan notifikasi di UI
      emit(OtpResendSuccess());
      // Kembali ke state initial agar UI tidak "terjebak" di state resend
      emit(OtpInitial());
    } catch (e) {
      emit(OtpVerificationFailure(e.toString()));
    }
  }
}