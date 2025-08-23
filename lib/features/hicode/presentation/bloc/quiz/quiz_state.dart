part of 'quiz_bloc.dart';

enum QuizStatus { initial, loading, success, submitted, failure } // Tambahkan 'failure'

class QuizState extends Equatable {
  const QuizState({
    this.status = QuizStatus.initial,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.error, // Tambahkan properti error
  });

  final QuizStatus status;
  final List<Map<String, dynamic>> questions;
  final int currentQuestionIndex;
  final Map<int, String> selectedAnswers;
  final String? error; // Properti baru

  QuizState copyWith({
    QuizStatus? status,
    List<Map<String, dynamic>>? questions,
    int? currentQuestionIndex,
    Map<int, String>? selectedAnswers,
    String? error, // Tambahkan di copyWith
  }) {
    return QuizState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }

  @override
  List<Object> get props => [status, questions, currentQuestionIndex, selectedAnswers];
}