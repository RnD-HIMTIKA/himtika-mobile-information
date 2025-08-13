import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<User?> getCurrentUser() async {
    final authUser = remote.getCurrentAuthUser();
    if (authUser == null) return null;
    final model = await remote.getUserByAuthId(authUser.id);
    return model;
  }

  @override
  Future<User?> getUserByAuthId(String authId) async {
    return await remote.getUserByAuthId(authId);
  }

  @override
  Future<supabase.AuthResponse> signUp(String email, String password) {
    return remote.signUpWithEmail(email, password);
  }

  @override
  Future<supabase.AuthResponse> signIn(String email, String password) {
    return remote.signInWithEmail(email, password);
  }

  @override
  Future<void> signInWithGoogle() {
    return remote.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return remote.signOut();
  }

  @override
  Future<void> updateProfile(String authId, Map<String, dynamic> changes) {
    return remote.updateUserProfile(authId, changes);
  }
}