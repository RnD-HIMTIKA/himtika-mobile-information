import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';

enum QuestionBankStatus { initial, loading, success, failure, submitting }

class QuestionBankState extends Equatable {
  final QuestionBankStatus status;
  final List<AdminQuestion> questions;
  final String? errorMessage;
  final Map<String, String> chaptersMap;
  final Map<String, String> materialsMap;

  const QuestionBankState({
    this.status = QuestionBankStatus.initial,
    this.questions = const [],
    this.errorMessage,
    this.chaptersMap = const {},
    this.materialsMap = const {},
  });

  QuestionBankState copyWith({
    QuestionBankStatus? status,
    List<AdminQuestion>? questions,
    String? errorMessage,
    bool clearError = false, // Helper untuk menghapus error
    Map<String, String>? chaptersMap,
    Map<String, String>? materialsMap,
  }) {
    return QuestionBankState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      chaptersMap: chaptersMap ?? this.chaptersMap,
      materialsMap: materialsMap ?? this.materialsMap,
    );
  }

  @override
  List<Object?> get props => [status, questions, errorMessage, chaptersMap, materialsMap];
}