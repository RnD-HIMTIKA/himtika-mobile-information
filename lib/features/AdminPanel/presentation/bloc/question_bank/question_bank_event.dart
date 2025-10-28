import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';

abstract class QuestionBankEvent extends Equatable {
  const QuestionBankEvent();
  @override
  List<Object?> get props => [];
}

// Event untuk memuat daftar soal
class LoadAdminQuestions extends QuestionBankEvent {
  const LoadAdminQuestions();
}

// Event saat tombol simpan di dialog tambah soal ditekan
class AddQuestionSubmitted extends QuestionBankEvent {
  final String relatedId; // Bisa ID Chapter atau ID Materi
  final String questionType; // QUIZ, FINAL_PRACTICE, OVERALL_EXAM
  final String difficulty; // Mudah, Menengah, Sulit
  final String questionText;
  final String? imageUrl; // Opsional
  final List<QuestionOptionInput> options;

  const AddQuestionSubmitted({
    required this.relatedId,
    required this.questionType,
    required this.difficulty,
    required this.questionText,
    this.imageUrl,
    required this.options,
  });

  @override
  List<Object?> get props => [
        relatedId,
        questionType,
        difficulty,
        questionText,
        imageUrl,
        options,
      ];
}

class LoadDropdownData extends QuestionBankEvent {
  const LoadDropdownData();
}

// TODO: Tambahkan event EditQuestionSubmitted, DeleteQuestionPressed nanti