import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_event.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/question_bank/question_bank_state.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'widgets/add_question_dialog.dart';

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
            return RefreshIndicator( // Tambahkan RefreshIndicator
              onRefresh: () async {
                 context.read<QuestionBankBloc>().add(const LoadAdminQuestions());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.questions.length,
                itemBuilder: (context, index) {
                  final question = state.questions[index];
                  // Format tanggal agar lebih mudah dibaca
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
                          Chip(label: Text('${question.optionCount} Opsi')), // Tampilkan jumlah opsi
                           IconButton(
                             icon: Icon(Icons.edit_note, color: AppColors.himfoBlue),
                             tooltip: 'Edit Soal',
                             onPressed: () {
                               // TODO: Implementasi Edit Dialog
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Fitur edit segera hadir!')),
                               );
                             },
                           ),
                           IconButton(
                             icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                              tooltip: 'Hapus Soal',
                             onPressed: () {
                               // TODO: Implementasi Delete Confirmation Dialog
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Fitur hapus segera hadir!')),
                               );
                             },
                           ),
                        ],
                      ),
                      isThreeLine: true, // Agar subtitle bisa lebih dari 1 baris
                      onTap: () {
                         // TODO: Implementasi Edit Dialog
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Fitur edit segera hadir!')),
                         );
                      },
                    ),
                  );
                },
                 separatorBuilder: (context, index) => const SizedBox(height: 0), // Tidak perlu separator jika sudah pakai Card
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

}