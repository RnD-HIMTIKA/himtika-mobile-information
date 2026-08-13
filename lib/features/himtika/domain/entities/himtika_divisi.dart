import 'package:equatable/equatable.dart';

class HimtikaDivisi extends Equatable {
  final String id;
  final String namaDivisi;
  final String? deskripsi;
  final String? logoUrl;
  final int urutan;

  const HimtikaDivisi({
    required this.id,
    required this.namaDivisi,
    this.deskripsi,
    this.logoUrl,
    this.urutan = 0,
  });

  HimtikaDivisi copyWith({
    String? id,
    String? namaDivisi,
    String? deskripsi,
    String? logoUrl,
    int? urutan,
  }) {
    return HimtikaDivisi(
      id: id ?? this.id,
      namaDivisi: namaDivisi ?? this.namaDivisi,
      deskripsi: deskripsi ?? this.deskripsi,
      logoUrl: logoUrl ?? this.logoUrl,
      urutan: urutan ?? this.urutan,
    );
  }

  @override
  List<Object?> get props => [id, namaDivisi, deskripsi, logoUrl, urutan];
}
