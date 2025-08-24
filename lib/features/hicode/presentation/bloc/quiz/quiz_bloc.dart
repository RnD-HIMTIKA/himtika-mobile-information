import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

final Map<String, List<Map<String, dynamic>>> _quizDatabase = {
  // Kunci ini cocok dengan ID dari sub-bab HTML
  '#Chapter 1 Pengantar HTML': [
    {
      'question': 'Tag HTML manakah yang digunakan untuk membuat paragraf?',
      'options': { 'A': '<p>', 'B': '<h1>', 'C': '<div>' },
      'correctAnswer': 'A',
    },
    {
      'question': 'Apa fungsi dari properti "background-color"?',
      'options': {
        'A': 'Mengubah warna border',
        'B': 'Mengubah warna latar belakang elemen',
        'C': 'Mengubah jenis font',
      },
      'correctAnswer': 'B',
    },
  ],
  // Kunci ini cocok dengan ID dari sub-bab CSS
  '#Chapter 2 Selektor dan Properti': [
    {
      'question': 'Tag HTML manakah yang digunakan untuk membuat paragraf?',
      'options': { 'A': '<p>', 'B': '<h1>', 'C': '<div>' },
      'correctAnswer': 'A',
    },
    {
      'question': 'Apa fungsi dari properti "background-color"?',
      'options': {
        'A': 'Mengubah warna border',
        'B': 'Mengubah warna latar belakang elemen',
        'C': 'Mengubah jenis font',
      },
      'correctAnswer': 'B',
    },
  ],
  // Kunci ini cocok dengan ID dari sub-bab JS
  '#Chapter 3 Pengenalan CSS': [
    {
      'question': 'Properti CSS manakah yang digunakan untuk mengubah warna teks?',
      'options': {
        'A': 'font-color',
        'B': 'text-color',
        'C': 'color',
      },
      'correctAnswer': 'C',
    },
    {
      'question': 'Apa fungsi dari properti "background-color"?',
      'options': {
        'A': 'Mengubah warna border',
        'B': 'Mengubah warna latar belakang elemen',
        'C': 'Mengubah jenis font',
      },
      'correctAnswer': 'B',
    },
  ],
  // Kunci ini cocok dengan ID dari sub-bab C++
  '#Chapter 4 Flexbox': [
    {
      'question': 'Tag HTML manakah yang digunakan untuk membuat paragraf?',
      'options': { 'A': '<p>', 'B': '<h1>', 'C': '<div>' },
      'correctAnswer': 'A',
    },
    {
      'question': 'Apa fungsi dari properti "background-color"?',
      'options': {
        'A': 'Mengubah warna border',
        'B': 'Mengubah warna latar belakang elemen',
        'C': 'Mengubah jenis font',
      },
      'correctAnswer': 'B',
    },
  ],

  
  'FINAL_HTML': [
    {
      'question': 'Elemen HTML mana yang digunakan untuk menampilkan gambar?',
      'options': {'A': '<picture>', 'B': '<image>', 'C': '<img>'},
      'correctAnswer': 'C',
    },
    {
      'question': 'Atribut apa yang wajib ada di dalam tag <img>?',
      'options': {'A': 'href', 'B': 'src', 'C': 'alt'},
      'correctAnswer': 'B',
    },
    {
      'question': 'Elemen HTML mana yang digunakan untuk menampilkan gambar?',
      'options': {'A': '<picture>', 'B': '<image>', 'C': '<img>'},
      'correctAnswer': 'C',
    },
    {
      'question': 'Atribut apa yang wajib ada di dalam tag <img>?',
      'options': {'A': 'href', 'B': 'src', 'C': 'alt'},
      'correctAnswer': 'B',
    },
    // ... tambahkan 8 soal lagi untuk HTML
  ],
  'FINAL_CSS': [
    {
      'question': 'Properti manakah yang digunakan untuk mengatur spasi di dalam sebuah elemen?',
      'options': {'A': 'margin', 'B': 'padding', 'C': 'border'},
      'correctAnswer': 'B',
    },
    {
      'question': 'Bagaimana cara membuat semua teks di dalam <h1> menjadi huruf kapital?',
      'options': {
        'A': 'text-transform: uppercase;',
        'B': 'font-style: uppercase;',
        'C': 'text-style: capital;',
      },
      'correctAnswer': 'A',
    },
    {
      'question': 'Properti manakah yang digunakan untuk mengatur spasi di dalam sebuah elemen?',
      'options': {'A': 'margin', 'B': 'padding', 'C': 'border'},
      'correctAnswer': 'B',
    },
    {
      'question': 'Bagaimana cara membuat semua teks di dalam <h1> menjadi huruf kapital?',
      'options': {
        'A': 'text-transform: uppercase;',
        'B': 'font-style: uppercase;',
        'C': 'text-style: capital;',
      },
      'correctAnswer': 'A',
    },
    // ... tambahkan 9 soal lagi untuk CSS
  ],
  'FINAL_JavaScript': [
    {
      'question': 'Operator mana yang digunakan untuk perbandingan nilai DAN tipe data?',
      'options': {'A': '==', 'B': '=', 'C': '==='},
      'correctAnswer': 'C',
    },
    {
      'question': 'Bagaimana cara memanggil fungsi bernama "myFunction"?',
      'options': {
        'A': 'call function myFunction()',
        'B': 'myFunction()',
        'C': 'panggil myFunction()',
      },
      'correctAnswer': 'B',
    },
    {
      'question': 'Operator mana yang digunakan untuk perbandingan nilai DAN tipe data?',
      'options': {'A': '==', 'B': '=', 'C': '==='},
      'correctAnswer': 'C',
    },
    {
      'question': 'Bagaimana cara memanggil fungsi bernama "myFunction"?',
      'options': {
        'A': 'call function myFunction()',
        'B': 'myFunction()',
        'C': 'panggil myFunction()',
      },
      'correctAnswer': 'B',
    },
    // ... tambahkan 9 soal lagi untuk JavaScript
  ],
  'FINAL_C++': [
    {
      'question': 'Library manakah yang harus di-include untuk menggunakan "cout"?',
      'options': {'A': '<stream>', 'B': '<iostream>', 'C': '<input>'},
      'correctAnswer': 'B',
    },
    {
      'question': 'Bagaimana cara membuat komentar satu baris di C++?',
      'options': {'A': '// Ini komentar', 'B': '/* Ini komentar */', 'C': '# Ini komentar'},
      'correctAnswer': 'A',
    },
    {
      'question': 'Library manakah yang harus di-include untuk menggunakan "cout"?',
      'options': {'A': '<stream>', 'B': '<iostream>', 'C': '<input>'},
      'correctAnswer': 'B',
    },
    {
      'question': 'Bagaimana cara membuat komentar satu baris di C++?',
      'options': {'A': '// Ini komentar', 'B': '/* Ini komentar */', 'C': '# Ini komentar'},
      'correctAnswer': 'A',
    },
    // ... tambahkan 9 soal lagi untuk C++
  ],

  // --- TAMBAHKAN KUIS UNTUK UJIAN AKHIR ---
  'OVERALL_EXAM': [
    {
      'question': 'Manakah yang BUKAN merupakan tipe data primitif di JavaScript?',
      'options': { 'A': 'String', 'B': 'Number', 'C': 'Object', 'D': 'Boolean' },
      'correctAnswer': 'C',
    },
    {
      'question': 'Manakah yang BUKAN merupakan tipe data primitif di JavaScript?',
      'options': { 'A': 'String', 'B': 'Number', 'C': 'Object', 'D': 'Boolean' },
      'correctAnswer': 'C',
    },
    {
      'question': 'Manakah yang BUKAN merupakan tipe data primitif di JavaScript?',
      'options': { 'A': 'String', 'B': 'Number', 'C': 'Object', 'D': 'Boolean' },
      'correctAnswer': 'C',
    },
    {
      'question': 'Manakah yang BUKAN merupakan tipe data primitif di JavaScript?',
      'options': { 'A': 'String', 'B': 'Number', 'C': 'Object', 'D': 'Boolean' },
      'correctAnswer': 'C',
    },
    // ... tambahkan soal-soal lainnya
  ],
  // Tambahkan data kuis untuk sub-materi lain di sini
};


class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(const QuizState()) {
    on<FetchQuiz>(_onFetchQuiz);
    on<AnswerSelected>(_onAnswerSelected);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<SubmitQuiz>(_onSubmitQuiz);
  }

  // 2. Ubah method _onFetchQuiz untuk mencari data di database
  Future<void> _onFetchQuiz(FetchQuiz event, Emitter<QuizState> emit) async {
    emit(state.copyWith(status: QuizStatus.loading));
    await Future.delayed(const Duration(seconds: 2));

    // Ambil data kuis dari database berdasarkan ID yang dikirim event
    final questions = _quizDatabase[event.quizId];

    if (questions != null) {
      // Jika kuis dengan ID tersebut ditemukan
      emit(state.copyWith(
        status: QuizStatus.success,
        quizId: event.quizId,
        questions: questions,
        currentQuestionIndex: 0,
        selectedAnswers: {},
        quizStartTime: DateTime.now(),
      ));
    } else {
      // Jika kuis tidak ditemukan, kirim state failure
      emit(state.copyWith(
        status: QuizStatus.failure,
        error: 'Kuis untuk materi "${event.quizId}" tidak ditemukan.',
      ));
    }
  }

  // Sisa method lainnya tidak perlu diubah
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

  void _onSubmitQuiz(SubmitQuiz event, Emitter<QuizState> emit) {
    // --- HITUNG DURASI ---
    final endTime = DateTime.now();
    Duration timeTaken = Duration.zero;
    if (state.quizStartTime != null) {
      timeTaken = endTime.difference(state.quizStartTime!);
    }
    
    int correctAnswers = 0;

    // Hitung jawaban yang benar
    for (int i = 0; i < state.questions.length; i++) {
      final question = state.questions[i];
      final correctAnswer = question['correctAnswer'];
      final userAnswer = state.selectedAnswers[i];

      if (userAnswer != null && userAnswer == correctAnswer) {
        correctAnswers++;
      }
    }

    // Tentukan syarat kelulusan (misalnya, minimal 1 jawaban benar)
    final bool isPassed = correctAnswers >= 1;

    emit(state.copyWith(
      status: QuizStatus.submitted,
      score: correctAnswers,
      isPassed: isPassed,
      timeTaken: timeTaken,
    ));
  }
}