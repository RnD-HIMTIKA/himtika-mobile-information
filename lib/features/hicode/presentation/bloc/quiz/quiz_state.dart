part of 'quiz_bloc.dart';

enum QuizStatus { initial, loading, success, submitting, submitted, failure }

class QuizState extends Equatable {
  final QuizStatus status;
  final String quizId;
  final List<HiCodeQuestion> questions; // Menggunakan entitas yang benar
  final int currentQuestionIndex;
  final Map<int, String> selectedAnswers; // Kunci: questionIndex, Nilai: optionId
  final QuizResult? result; // Hasil setelah submit
  final String? error;
  final DateTime? quizStartTime;
  final Duration? timeTaken;

  const QuizState({
    this.status = QuizStatus.initial,
    this.quizId = '',
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.result,
    this.error,
    this.quizStartTime,
    this.timeTaken,
  });

  // Hapus properti lama seperti score, isPassed, dll.
  // copyWith sudah benar dari implementasi sebelumnya.
  QuizState copyWith({
    QuizStatus? status,
    String? quizId,
    List<HiCodeQuestion>? questions,
    int? currentQuestionIndex,
    Map<int, String>? selectedAnswers,
    QuizResult? result,
    String? error,
    DateTime? quizStartTime,
    Duration? timeTaken,
  }) {
    return QuizState(
      status: status ?? this.status,
      quizId: quizId ?? this.quizId,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      result: result ?? this.result,
      error: error ?? this.error,
      quizStartTime: quizStartTime ?? this.quizStartTime,
      timeTaken: timeTaken ?? this.timeTaken,
    );
  }

  @override
  List<Object?> get props => [
        status,
        quizId,
        questions,
        currentQuestionIndex,
        selectedAnswers,
        result,
        error,
        quizStartTime,
        timeTaken
      ];
}