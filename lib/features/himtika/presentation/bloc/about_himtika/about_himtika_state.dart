part of 'about_himtika_bloc.dart';

enum AboutHimtikaStatus { initial, loading, success, failure }

class AboutHimtikaState extends Equatable {
  const AboutHimtikaState({
    this.status = AboutHimtikaStatus.initial,
    this.heroImagePath = '',
    this.aboutParagraph = '',
    this.visiParagraph = '',
    this.misiParagraph = '',
    this.logoMeanings = const [],
  });

  final AboutHimtikaStatus status;
  final String heroImagePath;
  final String aboutParagraph;
  final String visiParagraph;
  final String misiParagraph;
  final List<Map<String, String>> logoMeanings;

  AboutHimtikaState copyWith({
    AboutHimtikaStatus? status,
    String? heroImagePath,
    String? aboutParagraph,
    String? visiParagraph,
    String? misiParagraph,
    List<Map<String, String>>? logoMeanings,
  }) {
    return AboutHimtikaState(
      status: status ?? this.status,
      heroImagePath: heroImagePath ?? this.heroImagePath,
      aboutParagraph: aboutParagraph ?? this.aboutParagraph,
      visiParagraph: visiParagraph ?? this.visiParagraph,
      misiParagraph: misiParagraph ?? this.misiParagraph,
      logoMeanings: logoMeanings ?? this.logoMeanings,
    );
  }

  @override
  List<Object?> get props => [
        status,
        heroImagePath,
        aboutParagraph,
        visiParagraph,
        misiParagraph,
        logoMeanings
      ];
}
