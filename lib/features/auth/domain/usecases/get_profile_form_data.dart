import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

// Use case untuk mengambil data awal yang dibutuhkan form
class GetProfileFormData {
  final AuthRepository repository;
  final SupabaseClient client; // Dibutuhkan untuk akses tabel roles

  GetProfileFormData(this.repository, this.client);

  Future<ProfileFormDataResult> call() async {
    final authUser = await repository.getCurrentUser();
    if (authUser == null) {
      throw Exception('User not authenticated');
    }

    // Ambil data dari tabel 'users'
    final userRow = await client
        .from('users')
        .select('id, is_from_unsika, email')
        .eq('auth_id', authUser.authId)
        .single();

    final userId = userRow['id'] as String;
    final bool isFromUnsika = (userRow['is_from_unsika'] as bool?) ?? false;
    final String? email = userRow['email'] as String?;

    String? angkatan, fakultas, prodi;

    // Jika dari Unsika, ambil data role
    if (isFromUnsika) {
      final rolesRef = await client
          .from('user_roles')
          .select('roles(name, group_name)')
          .eq('user_id', userId);

      for (final item in (rolesRef as List)) {
        final role = item['roles'];
        if (role == null) continue;
        final group = (role['group_name'] as String?)?.toLowerCase();
        final name = role['name'] as String?;

        if (group == 'angkatan') angkatan = name;
        if (group == 'fakultas') fakultas = name;
        if (group == 'prodi') prodi = name;
      }
    }

    return ProfileFormDataResult(
      isFromUnsika: isFromUnsika,
      email: email,
      angkatan: angkatan,
      fakultas: fakultas,
      prodi: prodi,
    );
  }
}

// Class untuk menampung hasil dari use case
class ProfileFormDataResult extends Equatable {
  final bool isFromUnsika;
  final String? email;
  final String? angkatan;
  final String? fakultas;
  final String? prodi;

  const ProfileFormDataResult({
    required this.isFromUnsika,
    this.email,
    this.angkatan,
    this.fakultas,
    this.prodi,
  });

  @override
  List<Object?> get props => [isFromUnsika, email, angkatan, fakultas, prodi];
}