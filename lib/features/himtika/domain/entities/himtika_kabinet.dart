import 'package:equatable/equatable.dart';

class HimtikaKabinet extends Equatable {
  final String id;
  final String namaKabinet;
  final String? tagline;
  final String? deskripsi;
  final String? logoUrl;
  final String periode;
  final bool isActive;

  const HimtikaKabinet({
    required this.id,
    required this.namaKabinet,
    this.tagline,
    this.deskripsi,
    this.logoUrl,
    required this.periode,
    this.isActive = true,
  });

  HimtikaKabinet copyWith({
    String? id,
    String? namaKabinet,
    String? tagline,
    String? deskripsi,
    String? logoUrl,
    String? periode,
    bool? isActive,
  }) {
    return HimtikaKabinet(
      id: id ?? this.id,
      namaKabinet: namaKabinet ?? this.namaKabinet,
      tagline: tagline ?? this.tagline,
      deskripsi: deskripsi ?? this.deskripsi,
      logoUrl: logoUrl ?? this.logoUrl,
      periode: periode ?? this.periode,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        namaKabinet,
        tagline,
        deskripsi,
        logoUrl,
        periode,
        isActive,
      ];
}
