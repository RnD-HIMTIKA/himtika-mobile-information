import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String authId,
    required String username,
    required String fullName,
    required String email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? profileUrl,
    String? npm,
    String? nomorMahasiswa,
    required bool isEmailVerified,
    required bool isFromUnsika,
    required DateTime createdAt,
    String? password,
    DateTime? verifiedAt,
  }) : super(
          id: id,
          authId: authId,
          username: username,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          profileUrl: profileUrl,
          npm: npm,
          nomorMahasiswa: nomorMahasiswa,
          isEmailVerified: isEmailVerified,
          isFromUnsika: isFromUnsika,
          createdAt: createdAt,
          password: password,
          verifiedAt: verifiedAt,
        );

  factory UserModel.fromMap(Map<String, dynamic> m) {
    return UserModel(
      id: m['id'] as String,
      authId: (m['auth_id'] ?? '') as String,
      username: (m['username'] ?? '') as String,
      fullName: (m['full_name'] ?? '') as String,
      email: (m['email'] ?? '') as String,
      phoneNumber: m['phone_number'] as String?,
      dateOfBirth: m['date_of_birth'] != null ? DateTime.parse(m['date_of_birth']) : null,
      profileUrl: m['profile_url'] as String?,
      npm: m['npm'] as String?,
      nomorMahasiswa: m['nomor_mahasiswa'] as String?,
      isEmailVerified: (m['is_email_verified'] ?? false) as bool,
      isFromUnsika: (m['is_from_unsika'] ?? false) as bool,
      createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now(),
      password: m['password'] as String?,
      verifiedAt: m['verified_at'] != null ? DateTime.parse(m['verified_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auth_id': authId,
      'username': username,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'profile_url': profileUrl,
      'npm': npm,
      'nomor_mahasiswa': nomorMahasiswa,
      'is_email_verified': isEmailVerified,
      'is_from_unsika': isFromUnsika,
      'created_at': createdAt.toIso8601String(),
      'password': password,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }
}