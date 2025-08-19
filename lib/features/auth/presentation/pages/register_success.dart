import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/dashboard.dart'; // Placeholder untuk Homepage
import 'login.dart';

class RegisterSuccess extends StatelessWidget {
  // Tambahkan parameter untuk membedakan alur
  final bool fromOAuth;

  const RegisterSuccess({super.key, this.fromOAuth = false});

  @override
  Widget build(BuildContext context) {
    // Tentukan teks dan aksi tombol secara dinamis
    final String titleText = fromOAuth
        ? "Login Berhasil!"
        : "Akun Anda telah berhasil dibuat";
    
    final String subtitleText = fromOAuth
        ? "Selamat datang kembali. Klik tombol di bawah untuk melanjutkan."
        : "Silakan kembali ke halaman login untuk masuk.";

    final String buttonText = fromOAuth ? 'Lanjut ke Homepage' : 'Kembali ke Login';
    
    onButtonPressed() {
      if (fromOAuth) {
        // Arahkan ke homepage (saat ini menggunakan Dashboard sebagai placeholder)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } else {
        // Arahkan kembali ke halaman login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'src/features/login&register/images/success.png',
                height: 200,
              ),
              const SizedBox(height: 32),
              Text(
                titleText, // Gunakan teks dinamis
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "Plus Jakarta Sans",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff006ebd),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitleText, // Gunakan teks dinamis
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "Plus Jakarta Sans",
                  fontSize: 16,
                  color: Color(0xff006ebd),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onButtonPressed, // Gunakan aksi dinamis
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006ebd),
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText, // Gunakan teks dinamis
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}