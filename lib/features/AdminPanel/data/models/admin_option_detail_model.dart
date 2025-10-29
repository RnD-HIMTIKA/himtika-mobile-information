import '../../domain/entities/admin_option_detail.dart';

class AdminOptionDetailModel extends AdminOptionDetail {
  const AdminOptionDetailModel({
    required super.id,
    required super.optionText,
    required super.isCorrect,
    // super.imageUrl,
  });

  factory AdminOptionDetailModel.fromMap(Map<String, dynamic> map) {
    return AdminOptionDetailModel(
      id: map['id'],
      optionText: map['option_text'],
      isCorrect: map['is_correct'] ?? false,
      // imageUrl: map['image_url'],
    );
  }
}