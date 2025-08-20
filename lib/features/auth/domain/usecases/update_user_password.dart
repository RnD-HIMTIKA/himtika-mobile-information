import '../repositories/auth_repository.dart';

class UpdateUserPassword {
  final AuthRepository repository;

  UpdateUserPassword(this.repository);

  Future<void> call({required String password, required String confirmPassword}) async {
    // Logika validasi ditempatkan di sini
    if (password.length < 6) {
      throw Exception('Password minimal harus 6 karakter.');
    }
    if (password != confirmPassword) {
      throw Exception('Konfirmasi password tidak cocok.');
    }
    // CATATAN: Pengecekan terhadap password lama tidak bisa dilakukan di sini
    // karena kita tidak pernah menyimpan atau memiliki akses ke password lama pengguna.
    // Ini adalah praktik keamanan standar.
    return await repository.updateUserPassword(password);
  }
}