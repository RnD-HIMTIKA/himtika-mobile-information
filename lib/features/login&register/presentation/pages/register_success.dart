import 'package:flutter/material.dart';
import 'login.dart';

class RegisterSuccess extends StatelessWidget {
  const RegisterSuccess({super.key});

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
              Image.asset(
                'src/features/login&register/images/success.png',
                height: 200,
              ),
              const SizedBox(height: 32),
              const Text(
                "Your account has succesfully created",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Plus Jakarta Sans",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff006ebd),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Click button below here to login",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Plus Jakarta Sans",
                  fontSize: 16,
                  color: Color(0xff006ebd),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
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
                  'Back to Login',
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
