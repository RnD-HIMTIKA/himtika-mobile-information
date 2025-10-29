import '../../domain/entities/admin_question_detail.dart';
import 'admin_option_detail_model.dart'; // Import model opsi

class AdminQuestionDetailModel extends AdminQuestionDetail {
  const AdminQuestionDetailModel({
    required super.id,
    super.relatedId,
    required super.questionType,
    required super.difficulty,
    required super.questionText,
    super.imageUrl,
    required super.createdAt,
    required super.options,
  });

  factory AdminQuestionDetailModel.fromMap(Map<String, dynamic> map) {
    // Parsing list opsi
    final optionsList = (map['options'] as List<dynamic>?) ?? [];
    final options = optionsList
        .map((optMap) => AdminOptionDetailModel.fromMap(optMap as Map<String, dynamic>))
        .toList();

    return AdminQuestionDetailModel(
      id: map['id'],
      relatedId: map['related_id'],
      questionType: map['question_type'],
      difficulty: map['difficulty'],
      questionText: map['question_text'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
      options: options, // Masukkan list opsi yang sudah diparsing
    );
  }
}