import '../repositories/auth_repository.dart';

class VerifyPasswordResetOtp {
  final AuthRepository repository;

  VerifyPasswordResetOtp(this.repository);

  // PERBAIKAN: Menggunakan positional arguments sesuai definisi di repository
  Future<void> call(String email, String token) async {
    if (token.length != 6) {
      throw Exception('Kode OTP harus 6 digit.');
    }
    return await repository.verifyPasswordResetOtp(email, token);
  }
}