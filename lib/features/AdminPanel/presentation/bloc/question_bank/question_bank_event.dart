import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';

abstract class QuestionBankEvent extends Equatable {
  const QuestionBankEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdminQuestions extends QuestionBankEvent {
  const LoadAdminQuestions();
}

class AddQuestionSubmitted extends QuestionBankEvent {
  final String relatedId;
  final String questionType;
  final String difficulty;
  final String questionText;
  final String? imageUrl;
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

// Event untuk memulai fetch detail soal sebelum edit
class FetchQuestionDetailsForEdit extends QuestionBankEvent {
  final String questionId;
  const FetchQuestionDetailsForEdit({required this.questionId});

  @override
  List<Object?> get props => [questionId];
}

// --- Tambahkan Event Baru ---
class EditQuestionSubmitted extends QuestionBankEvent {
  final String questionId; // ID Soal yang diedit
  final String relatedId;
  final String questionType;
  final String difficulty;
  final String questionText;
  final String? imageUrl;
  final List<QuestionOptionInput> options;

  const EditQuestionSubmitted({
    required this.questionId,
    required this.relatedId,
    required this.questionType,
    required this.difficulty,
    required this.questionText,
    this.imageUrl,
    required this.options,
  });

   @override
  List<Object?> get props => [
        questionId, // Tambahkan questionId
        relatedId,
        questionType,
        difficulty,
        questionText,
        imageUrl,
        options,
      ];
}

class DeleteQuestionPressed extends QuestionBankEvent {
  final String questionId;
  const DeleteQuestionPressed({required this.questionId});

   @override
  List<Object?> get props => [questionId];
}