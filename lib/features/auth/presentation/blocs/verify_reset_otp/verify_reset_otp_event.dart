part of 'verify_reset_otp_bloc.dart';

abstract class VerifyResetOtpEvent extends Equatable {
  const VerifyResetOtpEvent();
  @override
  List<Object> get props => [];
}

class VerifyResetOtpSubmitted extends VerifyResetOtpEvent {
  final String email;
  final String token;
  const VerifyResetOtpSubmitted({required this.email, required this.token});
  @override
  List<Object> get props => [email, token];
}