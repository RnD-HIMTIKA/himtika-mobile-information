part of 'question_bank_bloc.dart'; // Pastikan ini 'part of'

// (Enum QuestionBankStatus dan QuestionBankFilter tetap sama)
enum QuestionBankStatus {
  initial,
  loading,
  success,
  failure,
  submitting,
  fetchingDetails
}
enum QuestionBankFilter { all, quiz, finalPractice, overallExam }


class QuestionBankState extends Equatable {
  final QuestionBankStatus status;
  final List<AdminQuestion> questions;
  final String? errorMessage;
  // --- PERUBAHAN TIPE DATA DI SINI ---
  final Map<String, AdminChapterMapEntry> chaptersMap; // Map<ChapterID, (Title, MaterialID)>
  // --- AKHIR PERUBAHAN ---
  final Map<String, String> materialsMap; // Map<MaterialID, Title>
  final AdminQuestionDetail? questionDetail;
  final QuestionBankFilter filter;
  final String? selectedMaterialId;
  final String? selectedChapterId;

  const QuestionBankState({
    this.status = QuestionBankStatus.initial,
    this.questions = const [],
    this.errorMessage,
    this.chaptersMap = const {}, // <-- Tetap default ke map kosong
    this.materialsMap = const {},
    this.questionDetail,
    this.filter = QuestionBankFilter.all,
    this.selectedMaterialId,
    this.selectedChapterId,
  });

  QuestionBankState copyWith({
    QuestionBankStatus? status,
    List<AdminQuestion>? questions,
    String? errorMessage,
    bool clearError = false,
    Map<String, AdminChapterMapEntry>? chaptersMap, // <-- Ubah Tipe Map
    Map<String, String>? materialsMap,
    AdminQuestionDetail? questionDetail,
    bool clearDetail = false,
    QuestionBankFilter? filter,
    String? selectedMaterialId,
    String? selectedChapterId,
    bool clearMaterialFilter = false,
    bool clearChapterFilter = false,
  }) {
    return QuestionBankState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      chaptersMap: chaptersMap ?? this.chaptersMap, // <-- Ubah Tipe Map
      materialsMap: materialsMap ?? this.materialsMap,
      questionDetail:
          clearDetail ? null : (questionDetail ?? this.questionDetail),
      filter: filter ?? this.filter,
      selectedMaterialId: clearMaterialFilter
          ? null
          : (selectedMaterialId ?? this.selectedMaterialId),
      selectedChapterId: clearChapterFilter
          ? null
          : (selectedChapterId ?? this.selectedChapterId),
    );
  }

  @override
  List<Object?> get props => [
        status,
        questions,
        errorMessage,
        chaptersMap, // <-- Tipe sudah baru
        materialsMap,
        questionDetail,
        filter,
        selectedMaterialId,
        selectedChapterId
      ];
}