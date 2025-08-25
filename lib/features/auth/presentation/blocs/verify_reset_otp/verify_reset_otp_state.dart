part of 'verify_reset_otp_bloc.dart';

abstract class VerifyResetOtpState extends Equatable {
  const VerifyResetOtpState();
  @override
  List<Object> get props => [];
}

class VerifyResetOtpInitial extends VerifyResetOtpState {}
class VerifyResetOtpLoading extends VerifyResetOtpState {}
class VerifyResetOtpSuccess extends VerifyResetOtpState {}
class VerifyResetOtpFailure extends VerifyResetOtpState {
  final String message;
  const VerifyResetOtpFailure(this.message);
  @override
  List<Object> get props => [message];
}