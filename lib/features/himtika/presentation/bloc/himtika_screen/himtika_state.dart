part of 'himtika_bloc.dart';

enum HimtikaStatus { initial, loading, success, failure }

class HimtikaState extends Equatable {
  const HimtikaState({
    this.status = HimtikaStatus.initial,
    this.importantParts = const [],
    this.kabinetName = 'SINERGIS',
    this.kabinetTagline =
        'Sinergi, Inovatif, Eksplorasi, Responsif, Generalis, Sistematis',
    this.kabinetLogoPath = 'src/features/himtika/images/kabinet.png',
  });

  final HimtikaStatus status;
  final List<Map<String, String>> importantParts;
  final String kabinetName;
  final String kabinetTagline;
  final String kabinetLogoPath;

  HimtikaState copyWith({
    HimtikaStatus? status,
    List<Map<String, String>>? importantParts,
    String? kabinetName,
    String? kabinetTagline,
    String? kabinetLogoPath,
  }) {
    return HimtikaState(
      status: status ?? this.status,
      importantParts: importantParts ?? this.importantParts,
      kabinetName: kabinetName ?? this.kabinetName,
      kabinetTagline: kabinetTagline ?? this.kabinetTagline,
      kabinetLogoPath: kabinetLogoPath ?? this.kabinetLogoPath,
    );
  }

  @override
  List<Object> get props =>
      [status, importantParts, kabinetName, kabinetTagline, kabinetLogoPath];
}