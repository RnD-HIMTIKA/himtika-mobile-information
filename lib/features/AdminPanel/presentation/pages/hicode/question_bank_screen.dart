import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_bloc.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'widgets/add_question_dialog.dart';
import 'widgets/edit_question_dialog.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';

class QuestionBankScreen extends StatelessWidget {
  const QuestionBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuestionBankBloc>()..add(const LoadAdminQuestions()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bank Soal HiCode'),
          backgroundColor: AppColors.himfoBlue,
          foregroundColor: AppColors.white,
        ),
        body: BlocConsumer<QuestionBankBloc, QuestionBankState>(
          listener: (context, state) {
            if (state.status == QuestionBankStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // Tampilkan loading indicator HANYA jika data belum ada sama sekali
            if (state.status == QuestionBankStatus.loading &&
                state.questions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // --- STRUKTUR UTAMA ---
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<QuestionBankBloc>()
                    .add(LoadAdminQuestions(filter: state.filter)); // Kirim filter saat ini
              },
              child: Stack( // Stack HANYA untuk loading overlay
                children: [
                  // --- PERBAIKAN 1: Gunakan Column ---
                  Column(
                    children: [
                      // --- Widget Filter ---
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: SegmentedButton<QuestionBankFilter>(
                          segments: const [
                            ButtonSegment(
                                value: QuestionBankFilter.all,
                                label: Text('All'),
                                icon: Icon(Icons.clear_all)),
                            ButtonSegment(
                                value: QuestionBankFilter.quiz,
                                label: Text('Quiz')),
                            ButtonSegment(
                                value: QuestionBankFilter.finalPractice,
                                label: Text('Final')),
                            ButtonSegment(
                                value: QuestionBankFilter.overallExam,
                                label: Text('Ujian')),
                          ],
                          selected: {state.filter},
                          onSelectionChanged:
                              (Set<QuestionBankFilter> newSelection) {
                            context
                                .read<QuestionBankBloc>()
                                .add(FilterChanged(newSelection.first));
                          },
                           style: SegmentedButton.styleFrom(
                             // Izinkan tombol mengecil jika perlu
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),

                      // --- PERBAIKAN 2: Logika Konten (List atau Pesan Kosong) ---
                      if (state.questions.isEmpty &&
                          state.status != QuestionBankStatus.loading)
                        // Tampilkan pesan jika tidak ada soal
                        Expanded( // <-- HARUS DIBUNGKUS EXPANDED
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Belum ada soal untuk filter ini.\nTekan tombol + untuk menambah.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        )
                      else
                        // Tampilkan daftar soal
                        Expanded( // <-- HARUS DIBUNGKUS EXPANDED
                          child: ListView.separated(
                            // Ubah padding agar tidak tertutup filter
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), 
                            itemCount: state.questions.length,
                            itemBuilder: (context, index) {
                              final question = state.questions[index];
                              final formattedDate =
                                  DateFormat('dd MMM yyyy, HH:mm')
                                      .format(question.createdAt.toLocal());

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(
                                    question.questionText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    'Tipe: ${question.questionType} | Kesulitan: ${question.difficulty}\n'
                                    'Terkait: ${question.relatedTitle ?? "-"}\n'
                                    'Dibuat: $formattedDate',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600]),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Chip(
                                          label: Text(
                                              '${question.optionCount} Opsi')),
                                      IconButton(
                                        icon: Icon(Icons.edit_note,
                                            color: AppColors.himfoBlue),
                                        tooltip: 'Edit Soal',
                                        onPressed: () {
                                          _showEditQuestionDialog(
                                              context, question);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline,
                                            color: Colors.red[700]),
                                        tooltip: 'Hapus Soal',
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                              context, question);
                                        },
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                  onTap: () {
                                    _showEditQuestionDialog(context, question);
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 0),
                          ),
                        ),
                    ],
                  ),

                  // --- Overlay Loading ---
                  // Tampilkan jika (sedang submit) ATAU (sedang loading TAPI sudah ada data)
                  if (state.status == QuestionBankStatus.submitting ||
                      (state.status == QuestionBankStatus.loading &&
                          state.questions.isNotEmpty))
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                _showAddQuestionDialog(context);
              },
              backgroundColor: AppColors.himfoBlue,
              child: const Icon(Icons.add, color: AppColors.white),
            );
          },
        ),
      ),
    );
  }

  // --- (Fungsi _showAddQuestionDialog, _showEditQuestionDialog, _showDeleteConfirmationDialog tetap sama) ---
  void _showAddQuestionDialog(BuildContext context) {
    final bloc = context.read<QuestionBankBloc>();
    bloc.add(const LoadDropdownData());
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: const AddQuestionDialog(),
        );
      },
    );
  }

  void _showEditQuestionDialog(BuildContext context, AdminQuestion question) async {
    final bloc = context.read<QuestionBankBloc>();
    bloc.add(const LoadDropdownData());
    bloc.add(FetchQuestionDetailsForEdit(questionId: question.id));

    final currentState = await bloc.stream
        .firstWhere((state) => state.status != QuestionBankStatus.fetchingDetails);

    if (currentState.status == QuestionBankStatus.success &&
        currentState.questionDetail != null &&
        context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider.value(
            value: bloc,
            child: EditQuestionDialog(questionDetail: currentState.questionDetail!),
          );
        },
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentState.errorMessage ?? 'Gagal memuat detail soal.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, AdminQuestion question) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Soal'),
          content: Text(
              'Anda yakin ingin menghapus soal "${question.questionText.substring(0, (question.questionText.length > 50 ? 50 : question.questionText.length)) + (question.questionText.length > 50 ? '...' : '')}"? Aksi ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context
                    .read<QuestionBankBloc>()
                    .add(DeleteQuestionPressed(questionId: question.id));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}