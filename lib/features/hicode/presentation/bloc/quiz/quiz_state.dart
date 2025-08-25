part of 'quiz_bloc.dart';

enum QuizStatus { initial, loading, success, submitted, failure }

class QuizState extends Equatable {
  const QuizState({
    this.status = QuizStatus.initial,
    this.quizId = '', // 1. Tambahkan properti quizId
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.error,
    this.score = 0,
    this.isPassed = false,
    this.quizStartTime, // 1. Tambahkan waktu mulai
    this.timeTaken,  // 2. Tambahkan durasi pengerjaan
  });

  final QuizStatus status;
  final String quizId;
  final List<Map<String, dynamic>> questions;
  final int currentQuestionIndex;
  final Map<int, String> selectedAnswers;
  final String? error;
  final int score;
  final bool isPassed;
  final DateTime? quizStartTime;
  final Duration? timeTaken;

  QuizState copyWith({
    QuizStatus? status,
    String? quizId,
    List<Map<String, dynamic>>? questions,
    int? currentQuestionIndex,
    Map<int, String>? selectedAnswers,
    String? error,
    int? score,
    bool? isPassed,
    DateTime? quizStartTime, // 3. Tambahkan di copyWith
    Duration? timeTaken,
  }) {
    return QuizState(
      status: status ?? this.status,
      quizId: quizId ?? this.quizId,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      error: error ?? this.error,
      score: score ?? this.score,
      isPassed: isPassed ?? this.isPassed,
      quizStartTime: quizStartTime ?? this.quizStartTime,
      timeTaken: timeTaken ?? this.timeTaken,
    );
  }

  @override
  List<Object?> get props => [ // 3. Tambahkan di props (dan pastikan List<Object?>)
        status,
        quizId,
        questions,
        currentQuestionIndex,
        selectedAnswers,
        error,
        score,
        isPassed,
        quizStartTime,
        timeTaken
      ];
}