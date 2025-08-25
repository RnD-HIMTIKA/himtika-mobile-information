import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'onboarding.dart';
import 'otp_verification.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
    _redirect(); // Langsung panggil redirect
  }

  Future<void> _redirect() async {
    // Logika redirect Anda tetap sama, tanpa permintaan izin
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final verificationEmail = prefs.getString('verification_email');

      if (verificationEmail != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OTPVerificationPage(email: verificationEmail)),
        );
        return;
      }

      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Onboarding()),
        );
      }
      // Jika sesi ada, listener di main.dart akan mengambil alih.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Image.asset(
            'src/features/login&register/images/logo.png',
            width: 180,
          ),
        ),
      ),
    );
  }
}