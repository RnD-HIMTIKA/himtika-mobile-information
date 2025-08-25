part of 'quiz_bloc.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object> get props => [];
}

class FetchQuiz extends QuizEvent {
  final String quizId;
  const FetchQuiz({required this.quizId});
}

class AnswerSelected extends QuizEvent {
  final int questionIndex;
  final String answerKey; // 'A', 'B', 'C', etc.
  const AnswerSelected({required this.questionIndex, required this.answerKey});
}

class NextQuestion extends QuizEvent {}
class PreviousQuestion extends QuizEvent {}
class SubmitQuiz extends QuizEvent {}