class AppRoles {
  // Group Names (Sesuai Database)
  static const String groupSystem = 'System';
  static const String groupHima = 'Pengurus'; 
  
  // Role Names (Sesuai Database - Harus persis huruf besar/kecilnya!)
  static const String developers = 'Developers';
  static const String rnd = 'RnD';
  static const String ketuaHimpunan = 'Ketua Himpunan';
  static const String wakilKetua = 'Wakil Ketua Himpunan';
  static const String sekretaris = 'Sekretaris Umum';
  static const String wakilSekretaris = 'Wakil Sekretaris Umum';
  static const String bendahara = 'Bendahara Umum';
  static const String wakilBendahara = 'Wakil Bendahara Umum';

  // Logic Helpers
  static const List<String> superAdmins = [developers, rnd];
  
  // Role yang Cuma Boleh 1 Orang (Singleton)
  static const List<String> exclusiveRoles = [
    ketuaHimpunan, 
    wakilKetua,
    sekretaris,
    wakilSekretaris,
    bendahara,
    wakilBendahara
  ];
}