part of 'otp_bloc.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object> get props => [];
}

// Event saat pengguna menekan tombol "Submit"
class VerifyOtpButtonPressed extends OtpEvent {
  final String otp;
  final String email;

  const VerifyOtpButtonPressed({required this.otp, required this.email});

  @override
  List<Object> get props => [otp, email];
}

// Event saat pengguna menekan tombol "Resend Code"
class ResendOtpButtonPressed extends OtpEvent {
  final String email;

  const ResendOtpButtonPressed({required this.email});

  @override
  List<Object> get props => [email];
}