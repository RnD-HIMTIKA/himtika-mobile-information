import 'package:equatable/equatable.dart';

class HimtikaPengurus extends Equatable {
  final String id;
  final String divisiId;
  final String nama;
  final String jabatan;
  final String? fotoUrl;
  final int urutan;

  const HimtikaPengurus({
    required this.id,
    required this.divisiId,
    required this.nama,
    required this.jabatan,
    this.fotoUrl,
    this.urutan = 0,
  });

  HimtikaPengurus copyWith({
    String? id,
    String? divisiId,
    String? nama,
    String? jabatan,
    String? fotoUrl,
    int? urutan,
  }) {
    return HimtikaPengurus(
      id: id ?? this.id,
      divisiId: divisiId ?? this.divisiId,
      nama: nama ?? this.nama,
      jabatan: jabatan ?? this.jabatan,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      urutan: urutan ?? this.urutan,
    );
  }

  @override
  List<Object?> get props => [id, divisiId, nama, jabatan, fotoUrl, urutan];
}
