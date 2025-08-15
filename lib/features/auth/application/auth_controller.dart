import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/injection_container.dart';
import '../../../main.dart'; // Import main.dart untuk mengakses navigatorKey
import '../domain/usecases/check_user_profile_completeness.dart';
import '../presentation/pages/form.dart';
import '../presentation/pages/register_success.dart';

class AuthController {
  final _supabase = Supabase.instance.client;
  final CheckUserProfileCompleteness _checkUserProfileCompleteness = sl();

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> checkAuthAndNavigate() async {
    final context = navigatorKey.currentContext;
    
    // INI KUNCI DEBUGGINGNYA
    if (context == null) {
      debugPrint("[AuthController] FAILED: Navigator context is not available at the moment of the call.");
      return;
    }

    if (_supabase.auth.currentUser == null) {
      debugPrint("[AuthController] No current user found. Aborting navigation.");
      return;
    }

    try {
      debugPrint("[AuthController] SUCCESS: Context is available. Checking profile completeness...");
      final isProfileComplete = await _checkUserProfileCompleteness();

      if (isProfileComplete) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RegisterSuccess()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ContinueWithGoogle()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memeriksa profil: ${e.toString()}')),
      );
    }
  }
}