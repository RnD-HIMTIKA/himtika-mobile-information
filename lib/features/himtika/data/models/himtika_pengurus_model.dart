import '../../domain/entities/himtika_pengurus.dart';

class HimtikaPengurusModel extends HimtikaPengurus {
  const HimtikaPengurusModel({
    required super.id,
    required super.divisiId,
    required super.nama,
    required super.jabatan,
    super.fotoUrl,
    super.urutan,
  });

  factory HimtikaPengurusModel.fromJson(Map<String, dynamic> json) {
    return HimtikaPengurusModel(
      id: json['id'] as String,
      divisiId: json['divisi_id'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      jabatan: json['jabatan'] as String? ?? '',
      fotoUrl: json['foto_url'] as String?,
      urutan: json['urutan'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'divisi_id': divisiId,
      'nama': nama,
      'jabatan': jabatan,
      'foto_url': fotoUrl,
      'urutan': urutan,
    };
  }
}
