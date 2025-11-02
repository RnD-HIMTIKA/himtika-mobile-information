part of 'question_bank_bloc.dart'; // <-- GANTI IMPORT DENGAN INI

// (Semua import lain dihapus dari sini)

abstract class QuestionBankEvent extends Equatable {
  const QuestionBankEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdminQuestions extends QuestionBankEvent {
  final QuestionBankFilter? filter;
  const LoadAdminQuestions({this.filter});

  @override
  List<Object?> get props => [filter];
}

class FilterChanged extends QuestionBankEvent {
  final QuestionBankFilter filter;
  const FilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
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

class FetchQuestionDetailsForEdit extends QuestionBankEvent {
  final String questionId;
  const FetchQuestionDetailsForEdit({required this.questionId});

  @override
  List<Object?> get props => [questionId];
}

class EditQuestionSubmitted extends QuestionBankEvent {
  final String questionId;
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
        questionId,
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