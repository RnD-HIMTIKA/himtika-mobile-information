part of 'question_bank_bloc.dart';

// Tambah status baru
enum QuestionBankStatus {
  initial,
  loading,
  success,
  failure,
  submitting,
  fetchingDetails
}

// --- TAMBAHKAN ENUM INI ---
enum QuestionBankFilter { all, quiz, finalPractice, overallExam }
// --- AKHIR TAMBAHAN ---

class QuestionBankState extends Equatable {
  final QuestionBankStatus status;
  final List<AdminQuestion> questions;
  final String? errorMessage;
  final Map<String, String> chaptersMap;
  final Map<String, String> materialsMap;
  final AdminQuestionDetail? questionDetail;
  final QuestionBankFilter filter; // <-- TAMBAHKAN PROPERTI INI

  const QuestionBankState({
    this.status = QuestionBankStatus.initial,
    this.questions = const [],
    this.errorMessage,
    this.chaptersMap = const {},
    this.materialsMap = const {},
    this.questionDetail,
    this.filter = QuestionBankFilter.all, // <-- TAMBAHKAN DEFAULT VALUE
  });

  QuestionBankState copyWith({
    QuestionBankStatus? status,
    List<AdminQuestion>? questions,
    String? errorMessage,
    bool clearError = false,
    Map<String, String>? chaptersMap,
    Map<String, String>? materialsMap,
    AdminQuestionDetail? questionDetail,
    bool clearDetail = false,
    QuestionBankFilter? filter, // <-- TAMBAHKAN DI COPYWITH
  }) {
    return QuestionBankState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      chaptersMap: chaptersMap ?? this.chaptersMap,
      materialsMap: materialsMap ?? this.materialsMap,
      questionDetail:
          clearDetail ? null : (questionDetail ?? this.questionDetail),
      filter: filter ?? this.filter, // <-- TAMBAHKAN DI COPYWITH
    );
  }

  @override
  List<Object?> get props => [
        status,
        questions,
        errorMessage,
        chaptersMap,
        materialsMap,
        questionDetail,
        filter // <-- TAMBAHKAN KE PROPS
      ];
}