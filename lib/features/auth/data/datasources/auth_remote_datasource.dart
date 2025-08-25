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
      // FIX: Tambahkan redirectTo secara eksplisit
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  /// sign out
  Future<void> signOut() async {
    // Gunakan auth helper
    await SupabaseAuthHelper.auth.signOut();
  }

  /// get current session user (raw auth user)
  supabase.User? getCurrentAuthUser() => SupabaseAuthHelper.auth.currentUser;

  Future<void> verifyOtp(String email, String token) async {
    await SupabaseAuthHelper.auth.verifyOTP(
      type: supabase.OtpType.signup,
      token: token,
      email: email,
    );
  }

  Future<void> resendSignUpOtp(String email) async {
    await SupabaseAuthHelper.auth.resend(
      type: supabase.OtpType.signup,
      email: email,
    );
  }

  Future<void> sendPasswordResetOtp(String email) async {
    await SupabaseAuthHelper.auth.resetPasswordForEmail(email);
  }

  Future<void> verifyPasswordResetOtp(String email, String token) async {
    // Fungsi ini akan memverifikasi OTP dan menyiapkan sesi untuk update password
    await SupabaseAuthHelper.auth.verifyOTP(
      type: supabase.OtpType.recovery,
      token: token,
      email: email,
    );
  }

  Future<void> updateUserPassword(String newPassword) async {
    // Fungsi ini hanya bisa dipanggil setelah verifyPasswordResetOtp berhasil
    await SupabaseAuthHelper.auth.updateUser(
      supabase.UserAttributes(password: newPassword),
    );
  }

  Future<void> updateFcmToken(String token) async {
    final authUser = SupabaseAuthHelper.auth.currentUser;
    if (authUser == null) return;
    await SupabaseTableHelper.table('users')
        .update({'fcm_token': token})
        .eq('auth_id', authUser.id);
  }
}