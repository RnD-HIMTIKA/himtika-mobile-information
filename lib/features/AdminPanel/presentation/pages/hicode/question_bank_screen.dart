import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_bloc.dart';
import 'package:intl/intl.dart';
import 'widgets/add_question_dialog.dart';
import 'widgets/edit_question_dialog.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';
// Import DTO baru
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_chapter_map_entry.dart';

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
            if (state.status == QuestionBankStatus.loading &&
                state.questions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<QuestionBankBloc>()
                    .add(const LoadAdminQuestions()); // Disederhanakan
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      // --- Filter 1: Tipe Soal (SegmentedButton) ---
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                        child: SegmentedButton<QuestionBankFilter>(
                          segments: const [
                            ButtonSegment(
                                value: QuestionBankFilter.all,
                                label: Text('Semua'),
                                icon: Icon(Icons.clear_all)),
                            ButtonSegment(
                                value: QuestionBankFilter.quiz,
                                label: Text('Kuis')),
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
                            // Pindahkan visualDensity ke DALAM styleFrom
                            visualDensity: VisualDensity.compact, 
                          ),
                          // visualDensity: VisualDensity.compact, // HAPUS DARI SINI
                          // --- AKHIR PERBAIKAN ---
                        ),
                      ),

                      // --- PERBAIKAN: DROPDOWN BERTINGKAT ---
                      // Tampilkan filter Materi jika (Kuis ATAU Final Practice)
                      if (state.filter == QuestionBankFilter.quiz ||
                          state.filter == QuestionBankFilter.finalPractice)
                        _buildMaterialDropdown(context, state),

                      // Tampilkan filter Chapter HANYA JIKA Tipe Kuis
                      if (state.filter == QuestionBankFilter.quiz)
                        _buildChapterDropdown(context, state),
                      // --- AKHIR PERBAIKAN ---

                      if (state.questions.isEmpty &&
                          state.status != QuestionBankStatus.loading)
                        Expanded(
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
                        Expanded(
                          child: ListView.separated(
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

  // --- WIDGET BARU: Filter Materi ---
  Widget _buildMaterialDropdown(BuildContext context, QuestionBankState state) {
    final dataMap = state.materialsMap;
    final hintText = 'Filter Materi';

    // Buat item dropdown
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem(
        value: null, // "Semua"
        child: Text(
          'Semua Materi',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      ...dataMap.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key, // key = MaterialID
          child: Text(entry.value,
              overflow: TextOverflow.ellipsis), // value = Nama Materi
        );
      }),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
      child: DropdownButtonFormField<String>(
        value: state.selectedMaterialId, // Nilai saat ini
        items: items,
        hint: Text(hintText),
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        onChanged: (newValue) {
          // Panggil event MaterialFilterChanged
          context
              .read<QuestionBankBloc>()
              .add(MaterialFilterChanged(newValue));
        },
      ),
    );
  }

  // --- WIDGET BARU: Filter Chapter (Bertingkat) ---
  Widget _buildChapterDropdown(BuildContext context, QuestionBankState state) {
    final allChaptersMap = state.chaptersMap;
    final selectedMaterialId = state.selectedMaterialId;
    final hintText = 'Filter Chapter';

    // Filter `allChaptersMap` berdasarkan `selectedMaterialId`
    final filteredChapters = Map.fromEntries(
      allChaptersMap.entries.where((entry) {
        // Jika tidak ada materi dipilih, tampilkan SEMUA chapter
        if (selectedMaterialId == null) return true;
        // Jika ada materi dipilih, tampilkan HANYA chapter yg materialId-nya cocok
        return entry.value.materialId == selectedMaterialId;
      }),
    );

    // Buat item dropdown dari map yang sudah difilter
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem(
        value: null, // "Semua"
        child: Text(
          'Semua Chapter${selectedMaterialId == null ? "" : " (di materi ini)"}',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      ...filteredChapters.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key, // key = ChapterID
          // value.title = "Nama Materi - Nama Chapter"
          // Kita potong "Nama Materi - " agar tidak redundan
          child: Text(entry.value.title.split(' - ').last,
              overflow: TextOverflow.ellipsis),
        );
      }),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
      child: DropdownButtonFormField<String>(
        value: state.selectedChapterId, // Nilai saat ini
        items: items,
        hint: Text(hintText),
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        onChanged: (newValue) {
          // Panggil event ChapterFilterChanged
          context
              .read<QuestionBankBloc>()
              .add(ChapterFilterChanged(newValue));
        },
      ),
    );
  }
  
  // ... (Sisa fungsi _showAddQuestionDialog, _showEditQuestionDialog, _showDeleteConfirmationDialog tetap sama) ...
  
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