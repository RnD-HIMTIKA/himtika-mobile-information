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

  @override
  List<Object?> get props => [id, divisiId, nama, jabatan, fotoUrl, urutan];
}
