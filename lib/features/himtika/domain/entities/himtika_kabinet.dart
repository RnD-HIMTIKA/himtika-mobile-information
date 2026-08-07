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
