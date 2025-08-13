import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../repositories/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository repository;
  SignUpWithEmail(this.repository);

  Future<supabase.AuthResponse> call(String email, String password) async {
    return await repository.signUp(email, password);
  }
}
