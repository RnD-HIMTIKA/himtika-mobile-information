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
      String questionType;
      String relatedId; // Tipe tetap String, tapi isinya UUID

      if (event.quizId.startsWith('FINAL_')) {
        questionType = 'FINAL_PRACTICE';
        // Ekstrak UUID setelah "FINAL_"
        relatedId = event.quizId.substring(6); // Ambil string setelah "FINAL_"
        // Validasi sederhana apakah itu UUID (opsional tapi bagus)
        if (relatedId.length != 36) { // Panjang UUID
           throw Exception('Format quizId untuk Latihan Final tidak valid.');
        }
      } else if (event.quizId == '00000000-0000-0000-0000-000000000000') { // Gunakan UUID placeholder
        questionType = 'OVERALL_EXAM';
        relatedId = event.quizId; // Gunakan UUID placeholder sebagai relatedId
      } else {
        // Asumsi ini adalah UUID chapter untuk tipe QUIZ
        questionType = 'QUIZ';
        relatedId = event.quizId;
         // Validasi sederhana apakah itu UUID (opsional tapi bagus)
        if (relatedId.length != 36) { // Panjang UUID
           throw Exception('Format quizId untuk Kuis Chapter tidak valid (bukan UUID).');
        }
      }

      // Panggil use case dengan relatedId (yang sekarang seharusnya UUID) dan questionType
      final questions = await _getQuestions(relatedId, questionType);

      // --- Periksa apakah soal kosong SETELAH fetch ---
      if (questions.isEmpty) {
         emit(state.copyWith(
           status: QuizStatus.success, // Tetap success, tapi list kosong
           quizId: event.quizId,
           questions: [], // Kirim list kosong
           currentQuestionIndex: 0,
           selectedAnswers: {},
           quizStartTime: DateTime.now(), // Tetap set start time
         ));
         // Tidak perlu throw error, biarkan UI menampilkan pesan "soal belum tersedia"
      } else {
         // --- Jika soal ADA, lanjutkan seperti biasa ---
         emit(state.copyWith(
           status: QuizStatus.success,
           quizId: event.quizId,
           questions: questions,
           currentQuestionIndex: 0,
           selectedAnswers: {},
           quizStartTime: DateTime.now(),
         ));
      }

    } catch (e) {
      // --- PERBAIKAN PESAN ERROR ---
      String message = "Gagal memuat soal kuis.";
      if (e.toString().toLowerCase().contains('socketexception')) {
        message = "Gagal memuat. Periksa koneksi internet Anda.";
      }
      emit(state.copyWith(status: QuizStatus.failure, error: message));
      // --- AKHIR PERBAIKAN ---
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
    // Jangan proses jika sudah submitting
    if (state.status == QuizStatus.submitting) return;

    emit(state.copyWith(status: QuizStatus.submitting, error: null)); // Hapus error lama saat mulai submit
    try {
      // ... (logika hitung timeTakenSeconds dan panggil _submitQuizAnswers) ...
       final Map<String, String> answersToSubmit = {};
        state.selectedAnswers.forEach((questionIndex, optionId) {
          final questionId = state.questions[questionIndex].id;
          answersToSubmit[questionId] = optionId;
        });

        final endTime = DateTime.now();
        final timeTakenDuration = state.quizStartTime != null ? endTime.difference(state.quizStartTime!) : Duration.zero;
        int? timeTakenSeconds;

        // PASTIKAN UUID UJIAN AKHIR BENAR DAN KONSISTEN
        const String overallExamId = '00000000-0000-0000-0000-000000000000'; // Definisikan di satu tempat
        if (state.quizId == overallExamId) {
            timeTakenSeconds = timeTakenDuration.inSeconds <= 0 ? 1 : timeTakenDuration.inSeconds;
        }

        // Debugging Print
        print('Submitting Quiz ID: ${state.quizId}');
        print('Calculated Duration (seconds): ${timeTakenDuration.inSeconds}');
        print('Time Taken Seconds Sent: $timeTakenSeconds'); // Nilai yang dikirim ke RPC

        final result = await _submitQuizAnswers(answersToSubmit, timeTakenSeconds: timeTakenSeconds);

      emit(state.copyWith(
        status: QuizStatus.submitted,
        result: result,
        timeTaken: timeTakenDuration,
      ));
    } catch (e) {
      // --- PERBAIKAN PESAN ERROR ---
      String message = "Gagal mengirim jawaban.";
      if (e.toString().toLowerCase().contains('socketexception')) {
        message = "Gagal mengirim. Periksa koneksi internet Anda.";
      } else if (e.toString().contains('Exception:')) {
         message = e.toString().replaceFirst('Exception: ', '');
      }
      
      final errorMessage = message.replaceFirst('PostgrestException', '');
      print('Submit Error: $errorMessage');
      emit(state.copyWith(status: QuizStatus.failure, error: errorMessage,));
      emit(state.copyWith(status: QuizStatus.success));
      // --- AKHIR PERBAIKAN ---
    }
  }
}