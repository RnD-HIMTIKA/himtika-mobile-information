import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    _initializeAndRedirect();
  }

  Future<void> _initializeAndRedirect() async {
    // Minta izin notifikasi terlebih dahulu
    await _requestNotificationPermission();

    // Lanjutkan ke logika redirect setelah 3 detik
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final verificationEmail = prefs.getString('verification_email');

      // 1. Cek apakah ada proses verifikasi yang tertunda
      if (verificationEmail != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OTPVerificationPage(email: verificationEmail)),
        );
        return; // Hentikan eksekusi
      }

      // 2. Jika tidak ada, lanjutkan ke logika sesi seperti biasa
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Onboarding()),
        );
      }
      // Jika sesi ADA, listener di main.dart akan mengambil alih.
    }
  }

  // Fungsi baru untuk meminta izin notifikasi
  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('Izin notifikasi diberikan.');
      } else {
        debugPrint('Izin notifikasi ditolak.');
      }
    } catch (e) {
      debugPrint('Gagal meminta izin notifikasi: $e');
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