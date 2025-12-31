class Lecturer {
  final String name;
  final String role;
  final String category;
  final String nidn;
  final String phone;
  final String email;
  final String photoUrl;

  Lecturer({
    required this.name,
    required this.role,
    required this.category,
    this.nidn = "-", // Kalau kosong, isi strip
    this.phone = "-", // Kalau kosong, isi strip
    this.email = "-", // Kalau kosong, isi strip
    this.photoUrl = "-",
  });
}
