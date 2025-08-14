import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../presentation/pages/form.dart';
import '../presentation/pages/register_success.dart';

class AuthController {
  final supabase = Supabase.instance.client;

  Future<void> signInWithGoogle(BuildContext context) async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  Future<void> checkAuthSession(BuildContext context) async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      final userId = session.user.id;

      final res = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ContinueWithGoogle()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterSuccess()));
      }
    }
  }
}