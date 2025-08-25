import 'package:firebase_messaging/firebase_messaging.dart';
import '../repositories/auth_repository.dart';

class UpdateFcmToken {
  final AuthRepository repository;

  UpdateFcmToken(this.repository);

  Future<void> call() async {
    try {
      // 1. Dapatkan token dari Firebase Messaging
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        // Gagal mendapatkan token
        return;
      }
      
      // 2. Dapatkan pengguna saat ini
      final user = await repository.getCurrentUser();
      if (user == null) {
        // Pengguna belum login, tidak perlu update
        return;
      }

      // 3. Panggil repository untuk menyimpan token
      await repository.updateFcmToken(fcmToken);

    } catch (e) {
      // Tangani error jika gagal (misal: log ke server)
      print('Gagal mengupdate FCM token: $e');
    }
  }
}