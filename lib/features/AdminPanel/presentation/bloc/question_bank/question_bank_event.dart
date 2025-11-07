part of 'question_bank_bloc.dart';

abstract class QuestionBankEvent extends Equatable {
  const QuestionBankEvent();
  @override
  List<Object?> get props => [];
}

// --- MODIFIKASI EVENT INI ---
// LoadAdminQuestions sekarang tidak perlu parameter,
// karena BLoC akan mengambil filter dari state-nya sendiri
class LoadAdminQuestions extends QuestionBankEvent {
  const LoadAdminQuestions();
}
// --- AKHIR MODIFIKASI ---

class FilterChanged extends QuestionBankEvent {
  final QuestionBankFilter filter;
  const FilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

// --- GANTI RelatedIdFilterChanged DENGAN DUA EVENT INI ---

// Dipanggil saat dropdown "Filter Materi" (Dropdown 1) berubah
class MaterialFilterChanged extends QuestionBankEvent {
  final String? materialId; // null jika memilih "Semua Materi"
  const MaterialFilterChanged(this.materialId);

  @override
  List<Object?> get props => [materialId];
}

// Dipanggil saat dropdown "Filter Chapter" (Dropdown 2) berubah
class ChapterFilterChanged extends QuestionBankEvent {
  final String? chapterId; // null jika memilih "Semua Chapter"
  const ChapterFilterChanged(this.chapterId);

  @override
  List<Object?> get props => [chapterId];
}
// --- AKHIR PENGGANTIAN ---


// (Sisa event: Add, LoadDropdown, FetchDetails, Edit, Delete tetap sama)

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