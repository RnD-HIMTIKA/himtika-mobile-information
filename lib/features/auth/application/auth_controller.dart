import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/injection_container.dart';
import '../../../main.dart'; // Import main.dart untuk mengakses navigatorKey
import '../domain/usecases/check_user_profile_completeness.dart';
import '../presentation/pages/form.dart';
import '../domain/usecases/update_fcm_token.dart';

class AuthController {
  final _supabase = Supabase.instance.client;
  final CheckUserProfileCompleteness _checkUserProfileCompleteness = sl();
  final UpdateFcmToken _updateFcmToken = sl();

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> checkAuthAndNavigate() async {
    final context = navigatorKey.currentContext;
    
    if (context == null) {
      debugPrint("[AuthController] FAILED: Navigator context is not available at the moment of the call.");
      return;
    }

    if (_supabase.auth.currentUser == null) {
      debugPrint("[AuthController] No current user found. Aborting navigation.");
      return;
    }

    try {
      await _updateFcmToken(); 
      
      debugPrint("[AuthController] SUCCESS: Context is available. Checking profile completeness...");
      final isProfileComplete = await _checkUserProfileCompleteness();

      if (isProfileComplete) {
        // Alur Login Langsung (dari OAuth/sesi ada) -> Langsung ke Homepage
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      } else {
        // Alur Mengisi Form (dari OAuth/sesi ada) -> Ke Form
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ContinueWithGoogle(fromOAuth: true)), // Tandai dari OAuth
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memeriksa profil: ${e.toString()}')),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      // Navigasi akan ditangani oleh listener onAuthStateChange di main.dart
    } catch (e) {
      // Handle error jika sign out gagal
      debugPrint("Error signing out: ${e.toString()}");
    }
  }
}