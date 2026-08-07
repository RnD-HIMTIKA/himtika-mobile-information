import '../../domain/entities/himtika_about.dart';

class HimtikaAboutModel extends HimtikaAbout {
  const HimtikaAboutModel({
    required super.id,
    required super.visi,
    required super.misi,
    required super.sejarahText,
  });

  factory HimtikaAboutModel.fromJson(Map<String, dynamic> json) {
    final rawMisi = json['misi'];
    List<String> parsedMisi = [];

    if (rawMisi is List) {
      parsedMisi = rawMisi.map((e) => e.toString()).toList();
    }

    return HimtikaAboutModel(
      id: json['id'] as String,
      visi: json['visi'] as String? ?? '',
      misi: parsedMisi,
      sejarahText: json['sejarah_text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visi': visi,
      'misi': misi,
      'sejarah_text': sejarahText,
    };
  }
}
