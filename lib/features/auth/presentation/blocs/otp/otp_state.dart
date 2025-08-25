part of 'otp_bloc.dart';

abstract class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object> get props => [];
}

// State awal saat halaman dibuka
class OtpInitial extends OtpState {}

// State saat proses verifikasi sedang berjalan (menampilkan loading)
class OtpVerificationLoading extends OtpState {}

// State jika verifikasi berhasil
class OtpVerificationSuccess extends OtpState {}

// State jika verifikasi gagal, membawa pesan error
class OtpVerificationFailure extends OtpState {
  final String error;

  const OtpVerificationFailure(this.error);

  @override
  List<Object> get props => [error];
}

// State sementara untuk notifikasi bahwa OTP berhasil dikirim ulang
class OtpResendSuccess extends OtpState {}