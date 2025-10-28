import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/hicode_question.dart';
import '../../../domain/entities/quiz_result.dart';
import '../../../domain/usecases/get_questions.dart';
import '../../../domain/usecases/submit_quiz_answers.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetQuestions _getQuestions;
  final SubmitQuizAnswers _submitQuizAnswers;

  QuizBloc({required GetQuestions getQuestions, required SubmitQuizAnswers submitQuizAnswers})
      : _getQuestions = getQuestions,
        _submitQuizAnswers = submitQuizAnswers,
        super(const QuizState()) {
    on<FetchQuiz>(_onFetchQuiz);
    on<AnswerSelected>(_onAnswerSelected);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<SubmitQuiz>(_onSubmitQuiz);
  }

  Future<void> _onFetchQuiz(FetchQuiz event, Emitter<QuizState> emit) async {
    emit(state.copyWith(status: QuizStatus.loading));
    try {
      // PERBAIKAN: Deklarasikan variabel di sini agar bisa diakses di seluruh blok
      String questionType;
      String relatedId = event.quizId; 
      if (event.quizId.startsWith('FINAL_')) {
        questionType = 'FINAL_PRACTICE';
        relatedId = event.quizId.replaceFirst('FINAL_', '');
      } else if (event.quizId == 'OVERALL_EXAM') {
        questionType = 'OVERALL_EXAM';
        // relatedId mungkin tidak relevan di sini
      } else {
        questionType = 'QUIZ';
        // relatedId sudah benar (UUID chapter)
      }
      final questions = await _getQuestions(relatedId, questionType);
      emit(state.copyWith(
        status: QuizStatus.success,
        quizId: event.quizId,
        questions: questions,
        currentQuestionIndex: 0,
        selectedAnswers: {},
        quizStartTime: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(status: QuizStatus.failure, error: e.toString()));
    }
  }

  void _onAnswerSelected(AnswerSelected event, Emitter<QuizState> emit) {
    final newAnswers = Map<int, String>.from(state.selectedAnswers);
    newAnswers[event.questionIndex] = event.answerKey;
    emit(state.copyWith(selectedAnswers: newAnswers));
  }
  
  void _onNextQuestion(NextQuestion event, Emitter<QuizState> emit) {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      emit(state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1));
    }
  }

  void _onPreviousQuestion(PreviousQuestion event, Emitter<QuizState> emit) {
    if (state.currentQuestionIndex > 0) {
      emit(state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  Future<void> _onSubmitQuiz(SubmitQuiz event, Emitter<QuizState> emit) async {
    // PERBAIKAN: Gunakan status 'submitting' yang sudah ada
    emit(state.copyWith(status: QuizStatus.submitting));
    try {
      final Map<String, String> answersToSubmit = {};
      state.selectedAnswers.forEach((questionIndex, optionId) {
        // PERBAIKAN: Akses .id dari entitas HiCodeQuestion
        final questionId = state.questions[questionIndex].id;
        answersToSubmit[questionId] = optionId;
      });

      final result = await _submitQuizAnswers(answersToSubmit);
      
      final endTime = DateTime.now();
      final timeTaken = state.quizStartTime != null ? endTime.difference(state.quizStartTime!) : Duration.zero;

      emit(state.copyWith(
        status: QuizStatus.submitted,
        result: result,
        timeTaken: timeTaken,
      ));
    } catch (e) {
      emit(state.copyWith(status: QuizStatus.failure, error: e.toString()));
    }
  }
}