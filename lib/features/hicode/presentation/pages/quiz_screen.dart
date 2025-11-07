import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/quiz/quiz_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/score_screen.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';
import 'package:himtika_mobile_information/core/helpers/image_optimizer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'dart:io' show Platform;

void _showZoomableImage(BuildContext context, String imageUrl) {
  // Ambil URL versi resolusi tinggi untuk zooming
  final zoomableUrl = ImageOptimizer.getOptimizedUrl(imageUrl, width: 1200, quality: 90);

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.8),
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                zoomableUrl,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50));
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(ctx).pop(),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black.withOpacity(0.5))
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


class QuizScreen extends StatelessWidget {
  final String quizId;
  final String? chapterTitle;

  const QuizScreen({
    super.key,
    required this.quizId,
    this.chapterTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<QuizBloc>()..add(FetchQuiz(quizId: quizId)),
      child: BlocListener<QuizBloc, QuizState>(
        listener: (context, state) { // Context di sini adalah context QuizScreen
          if (state.status == QuizStatus.submitted) {
            // Panggil fungsi global _showResultDialog
            _showResultDialog(context, state, quizId, chapterTitle); // Kirim context QuizScreen
          }
          else if (state.status == QuizStatus.failure && state.error != null) {
             // --- LOGIKA UNTUK ME-RESET FLAG ---
             
             // 1. Tampilkan SnackBar
             WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal submit: ${state.error}'), backgroundColor: Colors.red),
                  );
                }
             });
             
             // 2. Cari State dari _FinalExamView (jika ada) dan reset flag-nya
             final examViewState = context.findAncestorStateOfType<__FinalExamViewState>();
             if (examViewState != null && examViewState.mounted) {
                examViewState.setState(() {
                  examViewState._isSubmitted = false;
                });
             }
             // --- AKHIR LOGIKA RESET ---
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

                if (state.questions.isEmpty && state.status == QuizStatus.success) { // Tambahkan pengecekan status success
                  return Center(child: Text('Soal untuk ${state.quizId.startsWith('FINAL_') ? 'latihan final' : state.quizId == '00000000-0000-0000-0000-000000000000' ? 'ujian akhir' : 'kuis'} ini belum tersedia.'));
                }

                // Gabungkan kondisi untuk _QuizView dan _FinalExamView
                if (state.status == QuizStatus.success || state.status == QuizStatus.submitting) {
                  // Tampilkan _FinalExamView jika quizId adalah UUID Ujian Akhir
                  if (state.quizId == '00000000-0000-0000-0000-000000000000') {
                    return _FinalExamView(state: state);
                  } else {
                    // Selain itu, tampilkan _QuizView (untuk Kuis Chapter & Latihan Final)
                    return _QuizView(state: state, quizId: state.quizId, chapterTitle: chapterTitle); // Gunakan state.quizId
                  }
                }

                if (state.status == QuizStatus.failure) {
                  return Center(child: Text(state.error ?? 'Gagal memuat kuis.'));
                }

                return const SizedBox.shrink(); // Fallback
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext dialogContext, QuizState state, String currentQuizId, String? currentChapterTitle) {
  final result = state.result;
  if (result == null) return;

  final int correctAnswers = result.correctCount;
  final int totalQuestions = result.totalQuestions;
  final String quizId = currentQuizId; // Gunakan parameter
  final String? displayTitle = currentChapterTitle; // Gunakan parameter

  bool isPassed = false;
  String imagePath;
  String title = '';
  String subtitle = '';
  List<Widget> buttons = [];

  // --- LOGIKA KELULUSAN & PESAN (Sama seperti sebelumnya) ---
  if (quizId.startsWith('FINAL_')) { // Latihan Final
    final materialNameForDisplay = displayTitle ?? quizId; // Fallback
    isPassed = totalQuestions > 0 && (correctAnswers / totalQuestions) >= 0.6;

    if (isPassed) {
      title = 'Latihan Final Selesai!';
      subtitle = 'Hebat! Kamu lulus latihan final untuk "$materialNameForDisplay".';
      buttons = [
        _buildDialogButton( // Tombol ini dibuat sebagai fungsi helper statis atau di luar
          context: dialogContext, // Kirim context dialog
          text: 'Kembali ke Chapter',
          isPrimary: true,
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Tutup dialog
            // Keluar 2x: dari QuizScreen dan FinalExamDetailScreen/MaterialDetailScreen
            Navigator.of(dialogContext)..pop()..pop();
          },
        ),
      ];
    } else {
      title = 'Latihan Final Belum Tuntas';
      subtitle = 'Kamu menjawab benar $correctAnswers dari $totalQuestions soal ($materialNameForDisplay). Minimal 60% benar diperlukan...';
      buttons = [
        _buildDialogButton(
          context: dialogContext, // Kirim context dialog
          text: 'Kembali ke Detail Latihan',
          isPrimary: false,
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Tutup dialog
            Navigator.of(dialogContext).pop(); // Kembali dari QuizScreen
          },
        ),
        const SizedBox(height: 8),
        _buildDialogButton(
          context: dialogContext, // Kirim context dialog
          text: 'Ulangi Latihan Final',
          isPrimary: true,
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Tutup dialog
            // Dapatkan BLoC dari context dialog (yang mana adalah context QuizScreen)
            dialogContext.read<QuizBloc>().add(FetchQuiz(quizId: quizId));
          },
        ),
      ];
    }
  } else if (quizId == '00000000-0000-0000-0000-000000000000') { // Ujian Akhir
    isPassed = correctAnswers >= 15; // Syarat lulus Ujian Akhir
    title = 'Ujian Akhir Selesai!';
    subtitle = 'Kamu menjawab benar $correctAnswers dari $totalQuestions soal. Skor akhirmu adalah ${result.score} poin...'; // Pesan lengkap
    if (!isPassed) {
       subtitle += '\n\nSayangnya, kamu belum memenuhi syarat kelulusan (minimal 15 benar)...';
    }

    buttons = [
      _buildDialogButton(
        context: dialogContext, // Kirim context dialog
        text: 'Lihat Detail Skor',
        isPrimary: true,
        onPressed: () {
          Navigator.of(dialogContext).pop(); // Tutup dialog
          Navigator.of(dialogContext).pushReplacement( // Ganti halaman QuizScreen
            MaterialPageRoute(
              builder: (_) => ScoreScreen(
                score: result.score,
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                timeTaken: state.timeTaken ?? Duration.zero,
              ),
            ),
          );
        },
      ),
    ];
  } else { // Kuis Chapter Biasa
    final chapterNameForDisplay = displayTitle ?? 'Chapter'; // Fallback
    isPassed = (correctAnswers == totalQuestions && totalQuestions > 0);
    if (isPassed) {
      title = 'Kuis $chapterNameForDisplay Selesai!';
      subtitle = 'Kamu menjawab semua soal dengan benar...';
      buttons = [
        _buildDialogButton(
          context: dialogContext, // Kirim context dialog
          text: 'Lanjut Belajar',
          isPrimary: true,
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Tutup dialog
            // Pop 2 kali (keluar dari QuizScreen & SubChapterDetailScreen), kirim true
            Navigator.of(dialogContext).pop(true);
          },
        ),
      ];
    } else {
      title = 'Kuis $chapterNameForDisplay Belum Tuntas';
      subtitle = 'Kamu menjawab benar $correctAnswers dari $totalQuestions soal...';
      buttons = [
        _buildDialogButton(
          context: dialogContext, // Kirim context dialog
          text: 'Pelajari Ulang',
          isPrimary: true,
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Tutup dialog
            // Pop 1 kali (keluar dari QuizScreen), kirim false
            Navigator.of(dialogContext).pop(false);
          },
        ),
      ];
    }
  }
  // --- END LOGIKA ---

  imagePath = isPassed ? 'src/features/hicode/images/success.png' : 'src/features/hicode/images/failed.png';

  showDialog(
    context: dialogContext, // Gunakan context dialog
    barrierDismissible: false,
    builder: (_) { // Tidak perlu dialogContext lagi di sini
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath, height: 100),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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

  Widget _buildDialogButton({
    required BuildContext context, // Terima context
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
                  interval: 200.ms,
                  onPlay: (controller) => controller.repeat(),
                )
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
        ],
      ),
    );
  }
}

// --- UI UTAMA UNTUK KUIS ---
class _QuizView extends StatelessWidget {
  final QuizState state;
  final String quizId;
  final String? chapterTitle;

  const _QuizView({required this.state, required this.quizId, this.chapterTitle});

  @override
  Widget build(BuildContext context) {
    final currentQuestion = state.questions[state.currentQuestionIndex];

    return Column(
      children: [
        _buildTopBar(context, quizId, chapterTitle),
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
                  if (currentQuestion.imageUrl != null && currentQuestion.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Center( // Pusatkan gambar
                        // 3. BUNGKUS DENGAN GESTUREDETECTOR (GAMBAR SOAL)
                        child: GestureDetector(
                          onTap: () => _showZoomableImage(context, currentQuestion.imageUrl!),
                          child: Image.network(
                            // Gunakan URL optimasi yang sudah kita buat
                            ImageOptimizer.getOptimizedUrl(currentQuestion.imageUrl),
                            // Atur tinggi maksimum agar tidak terlalu besar
                            height: MediaQuery.of(context).size.height * 0.25,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(height: 100, child: Center(child: Icon(Icons.broken_image, color: Colors.grey)));
                            },
                          ),
                        ),
                      ),
                    ),
                  Text(
                    currentQuestion.questionText,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  ...currentQuestion.options.map((option) {
                    final isSelected =
                        state.selectedAnswers[state.currentQuestionIndex] ==
                            option.id;
                    return _OptionTile(
                      optionKey: '',
                      optionText: option.optionText,
                      imageUrl: option.imageUrl,
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

  Widget _buildTopBar(BuildContext context, String quizId, String? chapterTitle) {
    String title = 'Kuis'; // Default
    // Gunakan chapterTitle jika tersedia dan BUKAN Final/Overall
    if (chapterTitle != null && quizId != '00000000-0000-0000-0000-000000000000' && !quizId.startsWith('FINAL_')) {
       title = 'Kuis: $chapterTitle';
    // Gunakan chapterTitle jika tersedia dan INI Final (karena kita set judulnya di final_practice_detail)
    } else if (chapterTitle != null && quizId.startsWith('FINAL_')) {
       title = chapterTitle; // Langsung gunakan judul dari parameter
    } else if (quizId == '00000000-0000-0000-0000-000000000000') {
       title = 'Ujian Akhir HiCode';
    }

  return Container(
    color: const Color(0xFFDBF7FF),
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    child: Row(
      children: [
        IconButton(
          onPressed: () async {
            // Gunakan quizId dari parameter
            final bool? shouldExit = await _showExitQuizDialog(context, quizId); // <-- Gunakan parameter
            if (shouldExit == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          icon: Image.asset(
            'src/features/hicode/icon/kembali.png',
            width: 32,
            height: 32,
            color: AppColors.himfoBlue, // Beri warna biru agar terlihat di background cerah
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.himfoBlue,
            ),
            overflow: TextOverflow.ellipsis,
          ),
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
    } else if (quizId == '00000000-0000-0000-0000-000000000000') { // <-- Perbaiki ID Ujian Akhir
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
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile(
      {required this.optionKey,
      required this.optionText,
      this.imageUrl,
      required this.isSelected,
      required this.onTap
    });

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
            crossAxisAlignment: CrossAxisAlignment.start, // Align top jika ada gambar
            children: [
              // --- Lingkaran Pilihan ---
              Container(
                 margin: const EdgeInsets.only(top: 4), // Sedikit ke bawah agar sejajar teks
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
              // --- Konten Opsi (Teks + Gambar) ---
              Expanded(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // Tampilkan Gambar jika ada
                     if (imageUrl != null && imageUrl!.isNotEmpty)
                       Padding(
                         padding: const EdgeInsets.only(bottom: 8.0),
                         child: ClipRRect( // Clip gambar agar rounded
                            borderRadius: BorderRadius.circular(8),
                            // 4. BUNGKUS DENGAN GESTUREDETECTOR (GAMBAR OPSI)
                            child: GestureDetector(
                              onTap: () => _showZoomableImage(context, imageUrl!),
                              child: Image.network(
                                // Gunakan URL optimasi yang sudah kita buat
                                ImageOptimizer.getOptimizedUrl(imageUrl, width: 600, quality: 75),
                                height: 100, // Atur tinggi gambar opsi
                                width: double.infinity,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                   if (progress == null) return child;
                                   return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                                 },
                                 errorBuilder: (context, error, stackTrace) {
                                   return Container(height: 100, color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image)));
                                 },
                              ),
                            ),
                         ),
                       ),
                     // Tampilkan Teks Opsi
                     Text(optionText),
                   ],
                ),
              ),
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
            onPressed: (state.status == QuizStatus.submitting) ? null : () async { // Disable saat submitting
              // Panggil dialog dan tunggu hasilnya
              final bool? shouldSubmit = await _showSubmitConfirmationDialog(context);

              // Jika pengguna memilih "Submit" (true)
              if (shouldSubmit == true && context.mounted) { // Tambah cek context.mounted
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
            // Gunakan teks "Submit" saja
            child: (state.status == QuizStatus.submitting)
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2,))
              : const Text('Submit'),
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

class __FinalExamViewState extends State<_FinalExamView> with WidgetsBindingObserver {
  Timer? _timer;
  Duration _timeRemaining = const Duration(minutes: 30);
  bool _isSubmitted = false;
  final NoScreenshot _noScreenshot = NoScreenshot.instance;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _setupExamSecurity();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _releaseExamSecurity();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _setupExamSecurity() async {
    try {
      // 1. Jaga layar tetap menyala (WakelockPlus)
      await WakelockPlus.enable();
      print("Wakelock diaktifkan: Layar tidak akan mati.");
      
      // 2. GANTI IMPLEMENTASI BLOKIR SCREENSHOT
      await _noScreenshot.screenshotOff();
      print("Layar Ujian Akhir diamankan (Anti-Screenshot/Recording).");
      
    } catch (e) {
      print("Gagal mengatur keamanan layar: $e");
    }
  }

  Future<void> _releaseExamSecurity() async {
    try {
      // 1. Izinkan layar mati kembali (WakelockPlus)
      await WakelockPlus.disable();
      print("Wakelock dinonaktifkan.");

      // 2. GANTI IMPLEMENTASI MENGAKTIFKAN SCREENSHOT
      await _noScreenshot.screenshotOn();
      print("Pengaman layar Ujian Akhir dilepas.");
      
    } catch (e) {
      print("Gagal melepas keamanan layar: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Cek jika app di-pause (pindah app, lock screen, dll)
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Hanya submit jika ini Final Exam (quizId sudah pasti) DAN belum di-submit
      if (!_isSubmitted) {
        print("App Paused during Final Exam. Auto-submitting...");
        setState(() {
          _isSubmitted = true; // Tandai sudah di-submit
        });
        context.read<QuizBloc>().add(SubmitQuiz());
      }
    }
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
        if (context.mounted && !_isSubmitted) { // <-- TAMBAHKAN CEK !_isSubmitted
          print("Timer ran out. Auto-submitting...");
          setState(() {
            _isSubmitted = true; // Tandai sudah di-submit
          });
          context.read<QuizBloc>().add(SubmitQuiz());
        }
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

    if (_isSubmitted) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Sedang men-submit jawaban..."),
          ],
        ),
      );
    }

    final currentQuestion = widget.state.questions[widget.state.currentQuestionIndex];

    // --- TAMBAHKAN WIDGET INI ---
    return PopScope(
      // canPop: false berarti kita MENCEGAT tombol back
      canPop: false, 
      // onPopInvoked akan dipanggil saat user mencoba back
      onPopInvoked: (didPop) async {
        if (didPop) return; // Jika pop sudah terjadi (seharusnya tidak)

        // Panggil dialog kita. Jika user pilih "Keluar & Submit" (true)
        final bool? shouldExit = await _showExitFinalExamDialog(context);
        
        if (shouldExit == true && context.mounted && !_isSubmitted) {
          print("User pressed System Back. Auto-submitting...");
          setState(() {
            _isSubmitted = true; // Tandai sudah di-submit
          });
          context.read<QuizBloc>().add(SubmitQuiz());
        }
      },

      child: Column(
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
                  if (currentQuestion.imageUrl != null && currentQuestion.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Center(
                        // 5. BUNGKUS DENGAN GESTUREDETECTOR (UJIAN AKHIR - SOAL)
                        child: GestureDetector(
                          onTap: () => _showZoomableImage(context, currentQuestion.imageUrl!),
                          child: Image.network(
                            ImageOptimizer.getOptimizedUrl(currentQuestion.imageUrl),
                            height: MediaQuery.of(context).size.height * 0.25,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(height: 100, child: Center(child: Icon(Icons.broken_image, color: Colors.grey)));
                            },
                          ),
                        ),
                      ),
                    ),
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
                      imageUrl: option.imageUrl, // _OptionTile sudah di-update
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
    )
    );
  }

  Widget _buildFinalExamTopBar(BuildContext context, QuizState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              // --- MODIFIKASI LOGIKA DI SINI ---
              // Jangan panggil dialog lama, panggil dialog baru
              final bool? shouldExit = await _showExitFinalExamDialog(context);

              if (shouldExit == true && context.mounted && !_isSubmitted) {
                // Jika user menekan "Keluar & Submit"
                print("User pressed Exit & Submit. Auto-submitting...");
                setState(() {
                  _isSubmitted = true; // Tandai sudah di-submit
                });
                context.read<QuizBloc>().add(SubmitQuiz());
                // Kita tidak perlu pop, listener BLoC akan pushReplacement ke ScoreScreen
              }
              // Jika false (Batal), tidak terjadi apa-apa
              // --- AKHIR MODIFIKASI ---
            },
            icon: Image.asset(
              'src/features/hicode/icon/kembali.png',
              width: 32,
              height: 32,
              color: AppColors.himfoBlue,
            ),
          ),
          Expanded(
            child: Text('Ujian Akhir HiCode',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.himfoBlue)),
          ),
          const SizedBox(width: 48), // Placeholder
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

  Future<bool?> _showExitFinalExamDialog(BuildContext context) {
    return showDialog<bool>(
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
                Image.asset('src/features/hicode/icon/sirine.png', height: 80),
                const SizedBox(height: 16),
                const Text('Keluar dari Ujian?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text(
                  'Keluar dari halaman ini akan otomatis menyelesaikan ujian dan men-submit jawaban Anda. Aksi ini tidak bisa dibatalkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54)
                ),
                const SizedBox(height: 24),
                // Tombol Keluar & Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true), // Return TRUE
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Keluar & Submit'),
                  ),
                ),
                const SizedBox(height: 8),
                // Tombol Batal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false), // Return FALSE
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.black54,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Batal'),
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