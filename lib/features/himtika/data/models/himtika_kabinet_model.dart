import '../../domain/entities/himtika_kabinet.dart';

class HimtikaKabinetModel extends HimtikaKabinet {
  const HimtikaKabinetModel({
    required super.id,
    required super.namaKabinet,
    super.tagline,
    super.deskripsi,
    super.logoUrl,
    required super.periode,
    super.isActive,
  });

  factory HimtikaKabinetModel.fromJson(Map<String, dynamic> json) {
    return HimtikaKabinetModel(
      id: json['id'] as String,
      namaKabinet: json['nama_kabinet'] as String? ?? '',
      tagline: json['tagline'] as String?,
      deskripsi: json['deskripsi'] as String?,
      logoUrl: json['logo_url'] as String?,
      periode: json['periode'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kabinet': namaKabinet,
      'tagline': tagline,
      'deskripsi': deskripsi,
      'logo_url': logoUrl,
      'periode': periode,
      'is_active': isActive,
    };
  }
}
