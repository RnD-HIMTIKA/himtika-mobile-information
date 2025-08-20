import '../repositories/auth_repository.dart';

class ResendSignUpOtp {
  final AuthRepository repository;

  ResendSignUpOtp(this.repository);

  /// Memanggil proses pengiriman ulang OTP di repository.
  ///
  /// Throws an exception if the resend request fails.
  Future<void> call({required String email}) async {
    return await repository.resendSignUpOtp(email);
  }
}