import 'package:flutter/foundation.dart'; // Import untuk debugPrint
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
      debugPrint("[CheckProfile] User not found in public.users table. Profile is incomplete.");
      return false;
    }

    // --- DEBUGGING LOGS START ---
    debugPrint("--- [CheckProfile] Evaluating User Profile Data ---");
    debugPrint("Full Name      : '${user.fullName}'");
    debugPrint("Username       : '${user.username}'");
    debugPrint("Phone Number   : '${user.phoneNumber}'");
    debugPrint("Date of Birth  : ${user.dateOfBirth}");
    debugPrint("-------------------------------------------------");
    // --- DEBUGGING LOGS END ---


    // Cek apakah field yang wajib diisi di form sudah ada isinya.
    final isFullNameFilled = user.fullName.isNotEmpty;
    final isUsernameFilled = user.username.isNotEmpty;
    final isPhoneFilled = user.phoneNumber?.isNotEmpty ?? false;
    final isDobFilled = user.dateOfBirth != null;

    // --- DEBUGGING LOGS START ---
    debugPrint("isFullNameFilled: $isFullNameFilled");
    debugPrint("isUsernameFilled: $isUsernameFilled");
    debugPrint("isPhoneFilled   : $isPhoneFilled");
    debugPrint("isDobFilled     : $isDobFilled");
    // --- DEBUGGING LOGS END ---

    final bool isComplete = isFullNameFilled && isUsernameFilled && isPhoneFilled && isDobFilled;
    
    debugPrint("[CheckProfile] Final completeness result: $isComplete");
    
    return isComplete;
  }
}