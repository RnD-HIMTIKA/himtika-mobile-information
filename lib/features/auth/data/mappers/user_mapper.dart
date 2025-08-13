import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_model.dart';
import '../../domain/entities/user.dart';

class UserMapper {
  // Map (from public.users row) -> UserModel (uses existing UserModel.fromMap)
  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel.fromMap(Map<String, dynamic>.from(map));
  }

  // Entity -> Map (for updates)
  static Map<String, dynamic> toMap(User entity) {
    if (entity is UserModel) {
      return entity.toMap();
    }
    // Fallback mapping
    return {
      'id': entity.id,
      'auth_id': entity.authId,
      'username': entity.username,
      'full_name': entity.fullName,
      'email': entity.email,
      'phone_number': entity.phoneNumber,
      'date_of_birth': entity.dateOfBirth?.toIso8601String(),
      'profile_url': entity.profileUrl,
      'npm': entity.npm,
      'nomor_mahasiswa': entity.nomorMahasiswa,
      'is_email_verified': entity.isEmailVerified,
      'is_from_unsika': entity.isFromUnsika,
      'created_at': entity.createdAt.toIso8601String(),
      'verified_at': entity.verifiedAt?.toIso8601String(),
    };
  }

  // Optional: jika ingin map dari supabase.User (auth user)
  static UserModel fromAuthUser(supabase.User u) {
    final metadata = u.userMetadata ?? <String, dynamic>{};
    return UserModel(
      id: u.id,
      authId: u.id,
      username: (metadata['username'] ?? '') as String,
      fullName: (metadata['full_name'] ?? '') as String,
      email: u.email ?? '',
      phoneNumber: metadata['phone'] as String?,
      dateOfBirth: metadata['date_of_birth'] != null
          ? DateTime.tryParse(metadata['date_of_birth'] as String)
          : null,
      profileUrl: metadata['avatar_url'] as String?,
      npm: metadata['npm'] as String?,
      nomorMahasiswa: metadata['nomor_mahasiswa'] as String?,
      isEmailVerified: u.email != null, // fallback; refine as needed
      isFromUnsika: (u.email?.toLowerCase().endsWith('@student.unsika.ac.id') ?? false),
      createdAt: DateTime.now(),
      password: null,
      verifiedAt: null,
    );
  }
}