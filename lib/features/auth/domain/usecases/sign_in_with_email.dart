import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../repositories/auth_repository.dart';

class SignInWithEmail {
  final AuthRepository repository;
  SignInWithEmail(this.repository);

  Future<supabase.AuthResponse> call(String email, String password) async {
    return await repository.signIn(email, password);
  }
}