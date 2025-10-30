part of 'kabinet_bloc.dart';

enum KabinetStatus { initial, loading, success, failure }

class KabinetState extends Equatable {
  const KabinetState({
    this.status = KabinetStatus.initial,
    this.heroLogoPath = '',
    this.aboutSinergis = '',
    this.kabinetCards = const [],
    this.logoMeanings = const [],
  });

  final KabinetStatus status;
  final String heroLogoPath;
  final String aboutSinergis;
  final List<Map<String, String>> kabinetCards; 
  final List<Map<String, String>> logoMeanings; 

  KabinetState copyWith({
    KabinetStatus? status,
    String? heroLogoPath,
    String? aboutSinergis,
    List<Map<String, String>>? kabinetCards,
    List<Map<String, String>>? logoMeanings,
  }) {
    return KabinetState(
      status: status ?? this.status,
      heroLogoPath: heroLogoPath ?? this.heroLogoPath,
      aboutSinergis: aboutSinergis ?? this.aboutSinergis,
      kabinetCards: kabinetCards ?? this.kabinetCards,
      logoMeanings: logoMeanings ?? this.logoMeanings,
    );
  }

  @override
  List<Object?> get props =>
      [status, heroLogoPath, aboutSinergis, kabinetCards, logoMeanings];
}
