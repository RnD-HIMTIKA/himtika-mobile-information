import '../entities/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User?> getUserByAuthId(String authId);

  // Email/password flows return Supabase AuthResponse
  Future<supabase.AuthResponse> signUp(String email, String password);
  Future<supabase.AuthResponse> signIn(String email, String password);

  // OAuth redirect flow — jadi Future<void>
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<void> updateProfile(String authId, Map<String, dynamic> changes);
  Future<void> verifyOtp(String email, String token);
  Future<void> resendSignUpOtp(String email);

  Future<void> sendPasswordResetOtp(String email);
  Future<void> verifyPasswordResetOtp(String email, String token);
  Future<void> updateUserPassword(String newPassword);
}