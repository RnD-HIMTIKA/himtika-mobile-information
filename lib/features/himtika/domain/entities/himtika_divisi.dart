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

  @override
  List<Object?> get props => [id, namaDivisi, deskripsi, logoUrl, urutan];
}
