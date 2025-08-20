class User {
  final String id; // public.users.id (PK)
  final String authId; // auth.users.id
  final String username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? profileUrl;
  final String? npm;
  final String? nomorMahasiswa;
  final bool isEmailVerified;
  final bool isFromUnsika;
  final DateTime createdAt;
  final String? password; // hashed? client should NOT store raw password
  final DateTime? verifiedAt;

  User({
    required this.id,
    required this.authId,
    required this.username,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.profileUrl,
    this.npm,
    this.nomorMahasiswa,
    required this.isEmailVerified,
    required this.isFromUnsika,
    required this.createdAt,
    this.password,
    this.verifiedAt,
  });
}