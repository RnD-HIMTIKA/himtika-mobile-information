import 'package:equatable/equatable.dart';

class QuizResult extends Equatable {
  final int score;
  final int correctCount;
  final int totalQuestions;

  const QuizResult({
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [score, correctCount, totalQuestions];
}