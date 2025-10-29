import 'package:equatable/equatable.dart';
import 'admin_option_detail.dart'; // Import entity opsi

// Entity untuk menampung detail lengkap soal
class AdminQuestionDetail extends Equatable {
  final String id;
  final String? relatedId; // Nullable jika OVERALL_EXAM
  final String questionType;
  final String difficulty;
  final String questionText;
  final String? imageUrl;
  final DateTime createdAt;
  final List<AdminOptionDetail> options;

  const AdminQuestionDetail({
    required this.id,
    this.relatedId,
    required this.questionType,
    required this.difficulty,
    required this.questionText,
    this.imageUrl,
    required this.createdAt,
    required this.options,
  });

  @override
  List<Object?> get props => [
        id,
        relatedId,
        questionType,
        difficulty,
        questionText,
        imageUrl,
        createdAt,
        options,
      ];
}