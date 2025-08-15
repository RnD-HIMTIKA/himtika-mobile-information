import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/helpers/supabase_auth_helper.dart'; // Import helper
import '../../../../core/helpers/supabase_table_helper.dart'; // Import helper
import '../models/user_model.dart';
import '../mappers/user_mapper.dart';

class AuthRemoteDataSource {
  
  /// ambil public.users by auth_id
  Future<UserModel?> getUserByAuthId(String authId) async {
    // Gunakan table helper
    final res = await SupabaseTableHelper.table('users')
        .select()
        .eq('auth_id', authId)
        .maybeSingle();

    if (res == null) return null;
    return UserMapper.fromMap(res);
  }

  /// update profile
  Future<void> updateUserProfile(String authId, Map<String, dynamic> changes) async {
    // Gunakan table helper
    await SupabaseTableHelper.table('users')
        .update(changes)
        .eq('auth_id', authId);
  }

  /// sign up (email/password)
  Future<supabase.AuthResponse> signUpWithEmail(String email, String password) async {
    // Gunakan auth helper
    return await SupabaseAuthHelper.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// sign in email/password
  Future<supabase.AuthResponse> signInWithEmail(String email, String password) async {
    // Gunakan auth helper
    return await SupabaseAuthHelper.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // sign in with Google (redirect flow)
  Future<void> signInWithGoogle() async {
    // Gunakan auth helper
    await SupabaseAuthHelper.auth.signInWithOAuth(
      supabase.OAuthProvider.google,
      // redirectTo sesuaikan jika perlu untuk deep linking
    );
  }

  /// sign out
  Future<void> signOut() async {
    // Gunakan auth helper
    await SupabaseAuthHelper.auth.signOut();
  }

  /// get current session user (raw auth user)
  supabase.User? getCurrentAuthUser() => SupabaseAuthHelper.auth.currentUser;
}