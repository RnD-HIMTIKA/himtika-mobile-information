import '../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  /// Memanggil proses verifikasi OTP di repository.
  ///
  /// Throws an exception if the verification fails.
  Future<void> call({required String email, required String token}) async {
    // Validasi sederhana di use case, pastikan token tidak kosong
    if (token.length != 6) {
      throw Exception('Format OTP tidak valid.');
    }
    return await repository.verifyOtp(email, token);
  }
}