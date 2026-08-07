import 'package:equatable/equatable.dart';

class HimtikaAbout extends Equatable {
  final String id;
  final String visi;
  final List<String> misi;
  final String sejarahText;

  const HimtikaAbout({
    required this.id,
    required this.visi,
    required this.misi,
    required this.sejarahText,
  });

  @override
  List<Object?> get props => [id, visi, misi, sejarahText];
}
