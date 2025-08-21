import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/auth/presentation/pages/login.dart';

class PasswordChangedPage extends StatelessWidget {
  const PasswordChangedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gambar sukses
              Image.asset(
                'src/features/login&register/images/ilustrasi4.png',
                height: 200,
              ),
              const SizedBox(height: 32),

              // Judul
              const Text(
                "Password Berhasil Diubah",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Plus Jakarta Sans",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff006ebd),
                ),
              ),
              const SizedBox(height: 8),

              // Subjudul
              const Text(
                "Silakan login kembali menggunakan password baru Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Plus Jakarta Sans",
                  fontSize: 16,
                  color: Color(0xff006ebd),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol kembali ke login
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006ebd),
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Kembali ke Login",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
