import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case untuk memeriksa kelengkapan data profil user.
/// Mengembalikan `true` jika data penting (nama, username, telepon, tgl lahir) sudah terisi.
class CheckUserProfileCompleteness {
  final AuthRepository repository;

  CheckUserProfileCompleteness(this.repository);

  Future<bool> call() async {
    final User? user = await repository.getCurrentUser();

    // Jika user tidak ditemukan di tabel public.users, profil dianggap tidak lengkap.
    if (user == null) {
      return false;
    }

    // Cek apakah field yang wajib diisi di form sudah ada isinya.
    final isFullNameFilled = user.fullName.isNotEmpty;
    final isUsernameFilled = user.username.isNotEmpty;
    final isPhoneFilled = user.phoneNumber?.isNotEmpty ?? false;
    final isDobFilled = user.dateOfBirth != null;

    return isFullNameFilled && isUsernameFilled && isPhoneFilled && isDobFilled;
  }
}