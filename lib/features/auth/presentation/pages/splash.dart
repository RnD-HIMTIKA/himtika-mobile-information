import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'onboarding.dart';

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
    _redirect();
  }

  Future<void> _redirect() async {
    // Tunggu sebentar agar listener di main.dart punya waktu untuk bekerja
    await Future.delayed(const Duration(seconds: 3));

    // Cek setelah delay, apakah kita masih di halaman splash?
    // Jika ya, berarti tidak ada sesi aktif dan listener tidak melakukan apa-apa.
    // Maka, kita perlu bernavigasi secara manual.
    if (mounted) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Onboarding()),
        );
      }
      // Jika session ADA, berarti listener di main.dart SUDAH atau SEDANG
      // menangani navigasi. Jadi, splash screen tidak perlu melakukan apa-apa.
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