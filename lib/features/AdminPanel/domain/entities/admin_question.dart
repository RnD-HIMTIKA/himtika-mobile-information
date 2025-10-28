import 'package:equatable/equatable.dart';

class AdminQuestion extends Equatable {
  final String id;
  final String questionText;
  final String questionType;
  final String difficulty;
  final String? relatedTitle; // Judul chapter/materi/ujian
  final int optionCount;
  final DateTime createdAt;
  final String? relatedId;

  const AdminQuestion({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.difficulty,
    this.relatedTitle,
    required this.optionCount,
    required this.createdAt,
    this.relatedId,
  });

  @override
  List<Object?> get props => [
        id,
        questionText,
        questionType,
        difficulty,
        relatedTitle,
        optionCount,
        createdAt,
        relatedId,
      ];
}