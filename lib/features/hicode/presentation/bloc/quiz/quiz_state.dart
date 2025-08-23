part of 'quiz_bloc.dart';

enum QuizStatus { initial, loading, success, submitted, failure }

class QuizState extends Equatable {
  const QuizState({
    this.status = QuizStatus.initial,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.error,
    this.score = 0, // 1. Tambahkan skor
    this.isPassed = false, // 2. Tambahkan status kelulusan
  });

  final QuizStatus status;
  final List<Map<String, dynamic>> questions;
  final int currentQuestionIndex;
  final Map<int, String> selectedAnswers;
  final String? error;
  final int score; // Properti baru
  final bool isPassed; // Properti baru

  QuizState copyWith({
    QuizStatus? status,
    List<Map<String, dynamic>>? questions,
    int? currentQuestionIndex,
    Map<int, String>? selectedAnswers,
    String? error,
    int? score, // 3. Tambahkan di copyWith
    bool? isPassed, // Tambahkan di copyWith
  }) {
    return QuizState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      score: score ?? this.score,
      isPassed: isPassed ?? this.isPassed,
    );
  }

  @override
  List<Object> get props => [status, questions, currentQuestionIndex, selectedAnswers, score, isPassed];
}