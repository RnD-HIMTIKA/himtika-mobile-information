import '../../domain/entities/hicode_question.dart';
import 'hicode_option_model.dart'; // Pastikan import benar

class HiCodeQuestionModel extends HiCodeQuestion {
  const HiCodeQuestionModel({
    required super.id,
    required super.questionText,
    super.imageUrl,
    required super.options,
  });

  factory HiCodeQuestionModel.fromMap(Map<String, dynamic> map) {
    // Parsing list opsi dari format RPC baru (array of ROW)
    final optionsList = (map['options'] as List<dynamic>?) ?? [];
    final options = optionsList
        // Setiap elemen adalah Map yang mungkin berisi 'row'
        .map((opt) => HiCodeOptionModel.fromMap(opt as Map<String, dynamic>))
        .toList();

    return HiCodeQuestionModel(
      id: map['id'],
      questionText: map['question_text'],
      imageUrl: map['image_url'],
      options: options, // Masukkan list opsi yang sudah diparsing
    );
  }
}