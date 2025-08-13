import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_model.dart';
import '../mappers/user_mapper.dart'; // <-- pastikan file ini ada sesuai path

class AuthRemoteDataSource {
  final supabase.SupabaseClient client;
  AuthRemoteDataSource(this.client);

  /// ambil public.users by auth_id
  Future<UserModel?> getUserByAuthId(String authId) async {
    final res = await client
        .from('users')
        .select()
        .eq('auth_id', authId)
        .maybeSingle();

    if (res == null) return null;

    // Gunakan mapper supaya mapping konsisten di satu tempat
    return UserMapper.fromMap(res as Map<String, dynamic>);
  }

  /// ambil public.users by id
  Future<UserModel?> getUserById(String id) async {
    final res = await client
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (res == null) return null;

    return UserMapper.fromMap(res as Map<String, dynamic>);
  }

  /// update profile (username, full_name, phone, dob, profile_url)
  Future<void> updateUserProfile(String authId, Map<String, dynamic> changes) async {
    try {
      // tetap mempertahankan behaviour semula: lakukan update, ambil hasilnya (optional)
      final res = await client
          .from('users')
          .update(changes)
          .eq('auth_id', authId)
          .select()
          .maybeSingle();

      // jika ingin, bisa mengembalikan UserModel hasil update:
      // return res == null ? null : UserMapper.fromMap(res as Map<String, dynamic>);
      //
      // Namun signature tetap Future<void>, jadi kita tidak mengubahnya.
    } catch (e) {
      // rethrow agar lapisan repo / usecase dapat menangani error sesuai strategi error handling
      rethrow;
    }
  }

  /// sign up (email/password)
  Future<supabase.AuthResponse> signUpWithEmail(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// sign in email/password
  Future<supabase.AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // sign in with Google (redirect flow)
  Future<void> signInWithGoogle() async {
    // This triggers the redirect / native flow
    await client.auth.signInWithOAuth(
      supabase.OAuthProvider.google,
    );
  }

  /// sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// get current session user (raw auth user)
  supabase.User? getCurrentAuthUser() => client.auth.currentUser;
}