import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question_detail.dart'; // <-- Import

// Tambah status baru
enum QuestionBankStatus { initial, loading, success, failure, submitting, fetchingDetails }

class QuestionBankState extends Equatable {
  final QuestionBankStatus status;
  final List<AdminQuestion> questions;
  final String? errorMessage;
  final Map<String, String> chaptersMap;
  final Map<String, String> materialsMap;
  // Tambah state baru
  final AdminQuestionDetail? questionDetail; // Untuk menyimpan detail saat fetch

  const QuestionBankState({
    this.status = QuestionBankStatus.initial,
    this.questions = const [],
    this.errorMessage,
    this.chaptersMap = const {},
    this.materialsMap = const {},
    this.questionDetail, // Init null
  });

  QuestionBankState copyWith({
    QuestionBankStatus? status,
    List<AdminQuestion>? questions,
    String? errorMessage,
    bool clearError = false,
    Map<String, String>? chaptersMap,
    Map<String, String>? materialsMap,
    AdminQuestionDetail? questionDetail, // Tambah param
    bool clearDetail = false, // Helper untuk clear detail
  }) {
    return QuestionBankState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      chaptersMap: chaptersMap ?? this.chaptersMap,
      materialsMap: materialsMap ?? this.materialsMap,
      // Update state detail
      questionDetail: clearDetail ? null : (questionDetail ?? this.questionDetail),
    );
  }

  @override
  List<Object?> get props => [status, questions, errorMessage, chaptersMap, materialsMap, questionDetail]; // Tambah ke props
}