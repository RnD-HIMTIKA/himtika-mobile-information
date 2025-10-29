import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_event.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_state.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'widgets/add_question_dialog.dart';
import 'widgets/edit_question_dialog.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question_detail.dart';

class QuestionBankScreen extends StatelessWidget {
  const QuestionBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Buat instance BLoC dan langsung panggil event LoadAdminQuestions
      create: (_) => sl<QuestionBankBloc>()..add(const LoadAdminQuestions()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bank Soal HiCode'),
          backgroundColor: AppColors.himfoBlue,
          foregroundColor: AppColors.white,
        ),
        body: BlocConsumer<QuestionBankBloc, QuestionBankState>(
          listener: (context, state) {
            // Tampilkan snackbar jika ada error saat load atau submit
            if (state.status == QuestionBankStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
             // Tampilkan snackbar sukses saat berhasil menambah (opsional)
            // Bisa juga ditangani di dialognya langsung
            // else if (state.status == QuestionBankStatus.success && state.questions.isNotEmpty /*&& some flag indicating success after submit*/) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(content: Text('Soal berhasil ditambahkan!'), backgroundColor: Colors.green),
            //   );
            // }
          },
          builder: (context, state) {
            // Tampilkan loading indicator
            if (state.status == QuestionBankStatus.loading && state.questions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Tampilkan pesan jika tidak ada soal
            if (state.questions.isEmpty && state.status != QuestionBankStatus.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Belum ada soal di bank soal.\nTekan tombol + untuk menambah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            // Tampilkan daftar soal
            return RefreshIndicator(
              onRefresh: () async {
                 context.read<QuestionBankBloc>().add(const LoadAdminQuestions());
              },
              child: Stack( // <-- Bungkus ListView dengan Stack
                children: [
                  ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.questions.length,
                    itemBuilder: (context, index) {
                      final question = state.questions[index];
                      final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(question.createdAt.toLocal());

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                      title: Text(
                        question.questionText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Tipe: ${question.questionType} | Kesulitan: ${question.difficulty}\n'
                        'Terkait: ${question.relatedTitle ?? "-"}\n'
                        'Dibuat: $formattedDate',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(label: Text('${question.optionCount} Opsi')),
                               IconButton(
                                 icon: Icon(Icons.edit_note, color: AppColors.himfoBlue),
                                 tooltip: 'Edit Soal',
                                 onPressed: () {
                                   // Panggil dialog edit
                                   _showEditQuestionDialog(context, question);
                                 },
                               ),
                               IconButton(
                                 icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                                  tooltip: 'Hapus Soal',
                                 onPressed: () {
                                   // Panggil dialog konfirmasi hapus
                                   _showDeleteConfirmationDialog(context, question);
                                 },
                               ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                             // Panggil dialog edit saat list tile di-tap
                             _showEditQuestionDialog(context, question);
                          },
                        ),
                      );
                    },
                     separatorBuilder: (context, index) => const SizedBox(height: 0),
                  ),
                  // Tambahkan overlay loading saat submitting (Edit/Delete)
                  if (state.status == QuestionBankStatus.submitting)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: Builder( // Gunakan Builder agar context bisa akses BLoC
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                 // TODO: Panggil dialog tambah soal
                  _showAddQuestionDialog(context);
                 // ScaffoldMessenger.of(context).showSnackBar(
                 //   const SnackBar(content: Text('Dialog tambah soal segera hadir!')),
                 // );
              },
              backgroundColor: AppColors.himfoBlue,
              child: const Icon(Icons.add, color: AppColors.white),
            );
          }
        ),
      ),
    );
  }

  // --- Fungsi untuk menampilkan dialog tambah soal ---
  void _showAddQuestionDialog(BuildContext context) {
      final bloc = context.read<QuestionBankBloc>();
    // Panggil event untuk load dropdown SEBELUM dialog tampil
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

  void _showEditQuestionDialog(BuildContext context, AdminQuestion question) async { // <-- Jadikan async
      final bloc = context.read<QuestionBankBloc>();
      // Panggil event untuk load dropdown DULU
      bloc.add(const LoadDropdownData());

      // Panggil event untuk fetch detail dan TUNGGU
      bloc.add(FetchQuestionDetailsForEdit(questionId: question.id));

      // Tunggu sampai status berubah dari fetchingDetails atau terjadi failure
      final currentState = await bloc.stream.firstWhere(
         (state) => state.status != QuestionBankStatus.fetchingDetails
      );

      // Cek apakah fetch berhasil dan context masih valid
      if (currentState.status == QuestionBankStatus.success && currentState.questionDetail != null && context.mounted) {
         // Tampilkan dialog HANYA jika fetch berhasil
         showDialog(
           context: context,
           barrierDismissible: false,
           builder: (dialogContext) {
              return BlocProvider.value(
                 value: bloc,
                 // Kirim questionDetail ke dialog
                 child: EditQuestionDialog(questionDetail: currentState.questionDetail!),
              );
           },
         );
      } else if (context.mounted) {
         // Tampilkan pesan error jika fetch gagal
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(currentState.errorMessage ?? 'Gagal memuat detail soal.'),
             backgroundColor: Colors.red,
           ),
         );
      }
  }

  // --- Fungsi BARU untuk Dialog Konfirmasi Hapus ---
  void _showDeleteConfirmationDialog(BuildContext context, AdminQuestion question) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Soal'),
          content: Text('Anda yakin ingin menghapus soal "${question.questionText.substring(0, (question.questionText.length > 50 ? 50 : question.questionText.length)) + (question.questionText.length > 50 ? '...' : '')}"? Aksi ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Kirim event DeleteQuestionPressed ke BLoC
                context.read<QuestionBankBloc>().add(DeleteQuestionPressed(questionId: question.id));
                Navigator.of(dialogContext).pop(); // Tutup dialog konfirmasi
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}