import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/quiz/quiz_bloc.dart';

class QuizScreen extends StatelessWidget {
  final String quizId;
  const QuizScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizBloc()..add(FetchQuiz(quizId: quizId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<QuizBloc, QuizState>(
            builder: (context, state) {
              if (state.status == QuizStatus.loading ||
                  state.status == QuizStatus.initial) {
                return const _QuizLoadingScreen();
              }
              if (state.status == QuizStatus.success) {
                return _QuizView(state: state);
              }
              if (state.status == QuizStatus.submitted) {
                return const Center(child: Text('Kuis Selesai!'));
              }
              // --- TAMBAHKAN INI UNTUK MENANGANI ERROR ---
              if (state.status == QuizStatus.failure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      state.error ?? 'Terjadi kesalahan saat memuat kuis.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                );
              }
              return const Center(child: Text('Terjadi Kesalahan'));
            },
          ),
        ),
      ),
    );
  }
}

// --- UI UNTUK LOADING SCREEN ---
class _QuizLoadingScreen extends StatelessWidget {
  const _QuizLoadingScreen();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // 1. Animasi diterapkan langsung pada List<Widget>
            children: List.generate(5, (index) {
              return Container(
                width: 20,
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            })
                .animate(
                  // 2. Gunakan 'interval' sebagai parameter di sini
                  interval: 200.ms,
                  onPlay: (controller) => controller.repeat(),
                )
                // 3. Efek ini sekarang akan diterapkan secara bergiliran ke setiap buku
                .rotate(
                  begin: 0,
                  end: -0.2,
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .then(delay: 400.ms)
                .rotate(
                  begin: -0.2,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeIn,
                ),
          ),
          const SizedBox(height: 32),
          const Text('Menyiapkan Kuis...',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Harap tunggu sebentar. Kami sedang\nmenyiapkan soal-soal untuk kamu kerjakan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// --- UI UTAMA UNTUK KUIS ---
class _QuizView extends StatelessWidget {
  final QuizState state;
  const _QuizView({required this.state});

  @override
  Widget build(BuildContext context) {
    final currentQuestion = state.questions[state.currentQuestionIndex];
    final options = currentQuestion['options'] as Map<String, String>;

    return Column(
      children: [
        _buildTopBar(context),
        const SizedBox(height: 24),
        _ProgressIndicator(
          currentIndex: state.currentQuestionIndex,
          total: state.questions.length,
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion['question'],
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  // Pilihan Jawaban
                  ...options.entries.map((entry) {
                    final key = entry.key;
                    final value = entry.value;
                    final isSelected =
                        state.selectedAnswers[state.currentQuestionIndex] ==
                            key;
                    return _OptionTile(
                      optionKey: key,
                      optionText: value,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<QuizBloc>().add(AnswerSelected(
                              questionIndex: state.currentQuestionIndex,
                              answerKey: key,
                            ));
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        _BottomNavBar(state: state),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: const Color(0xFFDBF7FF),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              // Panggil dialog dan tunggu hasilnya
              final bool? shouldExit = await _showExitQuizDialog(context);

              // Jika pengguna memilih "Keluar Latihan" (true)
              if (shouldExit == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: Image.asset(
              'src/features/hicode/icon/kembali.png',
              width: 32,
              height: 32,
            ),
          ),
          const Expanded(
            child: Text('Kuis Chapter 1',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// --- WIDGET UNTUK PROGRESS INDICATOR ---
class _ProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int total;

  const _ProgressIndicator({required this.currentIndex, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (index) {
          return Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == currentIndex
                  ? Colors.blue
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: index == currentIndex ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// --- WIDGET UNTUK PILIHAN JAWABAN ---
class _OptionTile extends StatelessWidget {
  final String optionKey;
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile(
      {required this.optionKey,
      required this.optionText,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    optionKey,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade700),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(optionText)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET UNTUK NAVIGASI BAWAH ---
class _BottomNavBar extends StatelessWidget {
  final QuizState state;
  const _BottomNavBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final isFirstQuestion = state.currentQuestionIndex == 0;
    final isLastQuestion = state.currentQuestionIndex == state.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali
          IconButton(
            onPressed: isFirstQuestion
                ? null // Nonaktifkan jika soal pertama
                : () => context.read<QuizBloc>().add(PreviousQuestion()),
            icon: const Icon(Icons.arrow_back_ios_new),
            color: isFirstQuestion ? Colors.grey.shade300 : Colors.blue,
          ),
          // Tombol Submit
          ElevatedButton(
            onPressed: () => context.read<QuizBloc>().add(SubmitQuiz()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              side: const BorderSide(color: Colors.blue),
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Submit Kuis'),
          ),
          // Tombol Lanjut
          IconButton(
            onPressed: isLastQuestion
                ? null // Nonaktifkan jika soal terakhir
                : () => context.read<QuizBloc>().add(NextQuestion()),
            icon: const Icon(Icons.arrow_forward_ios),
            color: isLastQuestion ? Colors.grey.shade300 : Colors.blue,
          ),
        ],
      ),
    );
  }
}

Future<bool?> _showExitQuizDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: const Color(0xFFF5F9FF),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('src/features/hicode/icon/sirine.png', height: 80),
              const SizedBox(height: 16),
              const Text(
                'Yakin Ingin Keluar?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Anda sedang mengerjakan Latihan Soal Final. Keluar sekarang akan mengulang seluruh soal. Yakin ingin keluar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              // Tombol Tetap di halaman
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Tetap di halaman
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Keluar Latihan'),
                ),
              ),
              const SizedBox(height: 8),
              // Tombol Keluar Latihan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Keluar
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFFE0E0E0),
                    foregroundColor: Colors.black54,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Tetap di halaman'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}