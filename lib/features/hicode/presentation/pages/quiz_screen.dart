import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/quiz/quiz_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/score_screen.dart';

class QuizScreen extends StatelessWidget {
  final String quizId;
  const QuizScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<QuizBloc>()..add(FetchQuiz(quizId: quizId)),
      child: BlocListener<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state.status == QuizStatus.submitted) {
            _showResultDialog(context, state);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                if (state.status == QuizStatus.loading || state.status == QuizStatus.initial) {
                  return const _QuizLoadingView();
                }
                
                if (state.questions.isEmpty) {
                   return const Center(child: Text('Soal tidak ditemukan.'));
                }

                if (state.status == QuizStatus.success || state.status == QuizStatus.submitting) {
                  return state.quizId == 'OVERALL_EXAM'
                      ? _FinalExamView(state: state)
                      : _QuizView(state: state);
                }
                
                if (state.status == QuizStatus.failure) {
                  return Center(child: Text(state.error ?? 'Gagal memuat kuis.'));
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, QuizState state) {
    final result = state.result;
    // Lakukan pengecekan keamanan jika result null
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menampilkan hasil kuis.')),
      );
      return;
    }

    // PERBAIKAN: Ambil data dari objek 'result', bukan langsung dari 'state'
    final int score = result.correctCount;
    final int totalQuestions = result.totalQuestions;
    final bool isPassed = score >= (totalQuestions / 2); // Logika kelulusan
    final String quizId = state.quizId;

    // Tentukan konten dialog berdasarkan quizId dan status lulus
    String imagePath = isPassed
        ? 'src/features/hicode/images/success.png'
        : 'src/features/hicode/images/failed.png';
    String title = '';
    String subtitle = '';
    List<Widget> buttons = [];

    if (quizId.startsWith('FINAL_')) {
      // --- KONDISI 2: LATIHAN FINAL (per materi) ---
      if (isPassed) {
        title = 'Latihan Selesai';
        subtitle = 'Selamat, Anda telah menyelesaikan Latihan Soal Final bab ini. Anda bisa lanjut ke bab berikutnya.';
        buttons = [
          _buildDialogButton(
            text: 'Kembali ke Beranda',
            isPrimary: true,
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ];
      } else {
        title = 'Latihan Final\nBelum Tuntas';
        // PERBAIKAN: Gunakan variabel 'score' dan 'totalQuestions' yang sudah benar
        subtitle = 'Kamu menjawab benar $score dari $totalQuestions soal. Nilai masih belum cukup. Silakan ulang latihan soal final ini.';
        buttons = [
          _buildDialogButton(
            text: 'Pelajari Ulang Materi',
            isPrimary: true,
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              Navigator.of(context).pop(); // Kembali dari halaman kuis
            },
          ),
        ];
      }
    } else if (quizId == 'OVERALL_EXAM') {
      // --- KONDISI 3: UJIAN AKHIR (keseluruhan) ---
      imagePath = 'src/features/hicode/images/success.png';
      title = 'Selamat! Ujian Selesai';
      subtitle = 'Anda menyelesaikan Ujian Akhir HiCode. Jawabanmu telah disimpan dan skor tertinggimu akan tercatat di leaderboard.';
      buttons = [
        _buildDialogButton(
          text: 'Lihat Skor Anda',
          isPrimary: true,
          onPressed: () {
            Navigator.of(context).pop(); // Tutup dialog
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ScoreScreen(
                  // PERBAIKAN: Gunakan data dari 'result'
                  score: result.score, 
                  totalQuestions: result.totalQuestions,
                  timeTaken: state.timeTaken ?? Duration.zero,
                ),
              ),
            );
          },
        ),
      ];
    } else {
      // KONDISI 1: KUIS BAB BIASA
      title = isPassed ? 'Kuis Selesai' : 'Kuis Belum Tuntas';
      subtitle = isPassed
          ? 'Selamat, Anda telah menyelesaikan kuis pada bab ini. Materi berikutnya kini dapat diakses.'
          : 'Beberapa jawaban Anda belum benar. Silakan pelajari kembali materi pada chapter ini sebelum melanjutkan.';
      buttons = isPassed
          ? [
              _buildDialogButton(
                text: 'Materi Berikutnya',
                isPrimary: true,
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.of(context).pop(); // Kembali dari halaman kuis
                },
              ),
              const SizedBox(height: 8),
              _buildDialogButton(
                text: 'Kembali ke Beranda',
                isPrimary: false,
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ]
          : [
              _buildDialogButton(
                text: 'Pelajari Ulang Materi',
                isPrimary: true,
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.of(context).pop(); // Kembali dari halaman kuis
                },
              ),
            ];
    }

    // Tampilkan dialog dengan konten yang sudah ditentukan
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: const Color(0xFFF5F9FF),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(imagePath, height: 100),
                const SizedBox(height: 16),
                Text(title, textAlign: TextAlign.center,  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 24),
                ...buttons,
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget pembantu baru untuk membuat tombol agar tidak duplikat kode
  Widget _buildDialogButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: isPrimary ? Colors.blue : Colors.grey.shade200,
          foregroundColor: isPrimary ? Colors.white : Colors.black54,
          elevation: isPrimary ? 2 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(text),
      ),
    );
  }
}

// --- UI UNTUK LOADING SCREEN ---
class _QuizLoadingView extends StatelessWidget {
  const _QuizLoadingView();
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
    return Column(
      children: [
        // PERBAIKAN 2: Pemanggilan _buildTopBar disederhanakan.
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
                    currentQuestion.questionText, // Mengakses teks langsung dari currentQuestion
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  // Pilihan Jawaban
                  // Mengakses 'options' langsung dari currentQuestion
                  ...currentQuestion.options.map((option) { 
                    final isSelected = state.selectedAnswers[state.currentQuestionIndex] == option.id;
                    return _OptionTile(
                      optionKey: '', // Key visual tidak lagi relevan
                      optionText: option.optionText,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<QuizBloc>().add(AnswerSelected(
                              questionIndex: state.currentQuestionIndex,
                              answerKey: option.id,
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
    final String quizId = context.read<QuizBloc>().state.quizId;

    return Container(
      color: const Color(0xFFDBF7FF),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              // Kirim quizId ke fungsi dialog
              final bool? shouldExit = await _showExitQuizDialog(context, quizId);

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

  Future<bool?> _showExitQuizDialog(BuildContext context, String quizId) {
    // --- LOGIKA UNTUK KONTEN DIALOG DINAMIS ---
    String title = 'Yakin Ingin Keluar?';
    String subtitle = 'Anda sedang mengerjakan kuis. Keluar sekarang akan mengulang dari awal. Yakin ingin keluar?';
    String primaryButtonText = 'Keluar';
    String secondaryButtonText = 'Tetap di halaman';

    if (quizId.startsWith('FINAL_')) {
      // Kondisi untuk Latihan Final per materi
      subtitle = 'Anda sedang mengerjakan Latihan Soal Final. Keluar sekarang akan mengulang seluruh soal. Yakin ingin keluar?';
      primaryButtonText = 'Keluar Latihan';
    } else if (quizId == 'OVERALL_EXAM') {
      // Kondisi untuk Ujian Akhir keseluruhan
      subtitle = 'Anda sedang mengerjakan Ujian Akhir. Keluar sekarang akan mengulang seluruh soal-soal. Yakin ingin keluar?';
      primaryButtonText = 'Keluar Ujian';
    } else {
      // Kondisi untuk kuis bab biasa
      title = 'Keluar dari Kuis';
      subtitle = 'Kamu sedang mengerjakan kuis chapter ini. Jika keluar sekarang, akan diulang dari awal. Yakin ingin keluar?';
      primaryButtonText = 'Keluar Kuis';
    }

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: const Color(0xFFF5F9FF),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('src/features/hicode/icon/sirine.png', height: 80),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 24),
                // Tombol Tetap di Halaman
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(primaryButtonText),
                  ),
                ),
                const SizedBox(height: 8),
                // Tombol Keluar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.black54,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(secondaryButtonText),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    // Tentukan lebar total untuk progress bar
    const double totalBarWidth = 100.0;
    
    // Hitung lebar untuk bagian biru (progres)
    final double progressWidth = (totalBarWidth / total) * (currentIndex + 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      // 1. Bungkus semuanya dengan Column
      child: Column(
        children: [
          // Baris yang berisi lingkaran nomor (kode Anda sebelumnya)
          Row(
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
                      color:
                          index == currentIndex ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8), // Jarak antara nomor dan garis

          // 2. Buat progress bar menggunakan Stack
          Stack(
            children: [
              // Garis latar belakang (abu-abu)
              Container(
                width: totalBarWidth,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Garis progres (biru)
              Container(
                width: progressWidth, // Lebar dinamis sesuai progres
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
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
  final bool isFinalExam; // Tambahkan parameter ini

  const _BottomNavBar({required this.state, this.isFinalExam = false}); // Beri nilai default

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
            onPressed: () async {
              // Panggil dialog dan tunggu hasilnya
              final bool? shouldSubmit = await _showSubmitConfirmationDialog(context);

              // Jika pengguna memilih "Submit Kuis" (true)
              if (shouldSubmit == true) {
                context.read<QuizBloc>().add(SubmitQuiz());
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              side: const BorderSide(color: Colors.blue),
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(isFinalExam ? 'Submit Ujian' : 'Submit Kuis'),
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

Future<bool?> _showSubmitConfirmationDialog(BuildContext context) {
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
              const Text(
                'Kirim Jawaban',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kamu yakin ingin mengirim jawaban kuis ini sekarang? Jawaban yang sudah dikirim tidak bisa diubah kembali.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              // Tombol Submit Kuis
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Kirim jawaban
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Submit Kuis'),
                ),
              ),
              const SizedBox(height: 8),
              // Tombol Kembali
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Batal
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
                  child: const Text('Kembali'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// --- UI UTAMA BARU UNTUK UJIAN AKHIR ---
class _FinalExamView extends StatefulWidget {
  final QuizState state;
  const _FinalExamView({required this.state});

  @override
  State<_FinalExamView> createState() => __FinalExamViewState();
}

class __FinalExamViewState extends State<_FinalExamView> {
  Timer? _timer;
  Duration _timeRemaining = const Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeRemaining.inSeconds > 0) {
        setState(() {
          _timeRemaining -= const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
        // Auto-submit jika waktu habis
        context.read<QuizBloc>().add(SubmitQuiz());
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.state.questions[widget.state.currentQuestionIndex];

    return Column(
      children: [
        _buildFinalExamTopBar(context, widget.state),
        const SizedBox(height: 16),
        _buildFinalExamProgressBar(widget.state),
        const SizedBox(height: 16),
        _buildTimer(), // Timer sekarang menggunakan state internal
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion.questionText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  ...currentQuestion.options.map((option) {
                    final isSelected = widget.state.selectedAnswers[widget.state.currentQuestionIndex] == option.id;
                    return _OptionTile( // Menggunakan kembali widget _OptionTile
                      optionKey: '',
                      optionText: option.optionText,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<QuizBloc>().add(AnswerSelected(
                              questionIndex: widget.state.currentQuestionIndex,
                              answerKey: option.id,
                            ));
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        _BottomNavBar(state: widget.state, isFinalExam: true),
      ],
    );
  }

  // --- WIDGET-WIDGET PEMBANTU UNTUK UJIAN AKHIR ---
  Widget _buildFinalExamTopBar(BuildContext context, QuizState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              // 3. Perbaiki pemanggilan dialog
              final quizView = _QuizView(state: state);
              final bool? shouldExit = await quizView._showExitQuizDialog(context, state.quizId);

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
            child: Text('Ujian Akhir HiCode',
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

  Widget _buildFinalExamProgressBar(QuizState state) {
    final double progress = state.questions.isEmpty ? 0 : (state.currentQuestionIndex + 1) / state.questions.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${state.currentQuestionIndex + 1}/${state.questions.length}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            '${_formatDuration(_timeRemaining)} Waktu Tersisa', // Gunakan state waktu
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// Widget untuk setiap pilihan jawaban Ujian Akhir
class _FinalExamOptionTile extends StatelessWidget {
  final String optionKey;
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  const _FinalExamOptionTile(
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
