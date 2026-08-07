import '../../domain/entities/himtika_divisi.dart';

class HimtikaDivisiModel extends HimtikaDivisi {
  const HimtikaDivisiModel({
    required super.id,
    required super.namaDivisi,
    super.deskripsi,
    super.logoUrl,
    super.urutan,
  });

  factory HimtikaDivisiModel.fromJson(Map<String, dynamic> json) {
    return HimtikaDivisiModel(
      id: json['id'] as String,
      namaDivisi: json['nama_divisi'] as String? ?? '',
      deskripsi: json['deskripsi'] as String?,
      logoUrl: json['logo_url'] as String?,
      urutan: json['urutan'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_divisi': namaDivisi,
      'deskripsi': deskripsi,
      'logo_url': logoUrl,
      'urutan': urutan,
    };
  }
}
