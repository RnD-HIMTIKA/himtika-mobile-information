import '../../domain/entities/hicode_question.dart';
import 'hicode_option_model.dart';

class HiCodeQuestionModel extends HiCodeQuestion {
  const HiCodeQuestionModel({
    required super.id,
    required super.questionText,
    super.imageUrl,
    required super.options,
  });

  factory HiCodeQuestionModel.fromMap(Map<String, dynamic> map) {
    final optionsList = (map['options'] as List<dynamic>?) ?? [];
    return HiCodeQuestionModel(
      id: map['id'],
      questionText: map['question_text'],
      imageUrl: map['image_url'],
      options: optionsList.map((opt) => HiCodeOptionModel.fromMap(opt)).toList(),
    );
  }
}