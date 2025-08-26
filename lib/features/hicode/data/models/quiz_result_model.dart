import '../../domain/entities/quiz_result.dart';

class QuizResultModel extends QuizResult {
  const QuizResultModel({
    required super.score,
    required super.correctCount,
    required super.totalQuestions,
  });

  factory QuizResultModel.fromMap(Map<String, dynamic> map) {
    return QuizResultModel(
      score: map['score'] ?? 0,
      correctCount: map['correct_count'] ?? 0,
      totalQuestions: map['total_questions'] ?? 0,
    );
  }
}