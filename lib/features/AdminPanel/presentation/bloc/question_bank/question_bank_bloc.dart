// features/AdminPanel/presentation/bloc/question_bank/question_bank_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
// --- TAMBAHKAN IMPOR YANG DIPERLUKAN OLEH EVENT & STATE ---
import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question_detail.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
// --- AKHIR TAMBAHAN IMPOR ---

import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/create_question_with_options.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_admin_questions.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/update_question_with_options.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/delete_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_question_details.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_all_admin_chapters_map.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_all_admin_materials_map.dart';

part 'question_bank_event.dart';
part 'question_bank_state.dart'; // <-- 'part of' di file ini sekarang valid

class QuestionBankBloc extends Bloc<QuestionBankEvent, QuestionBankState> {
  final GetAdminQuestions _getAdminQuestions;
  final CreateQuestionWithOptions _createQuestionWithOptions;
  final UpdateQuestionWithOptions _updateQuestionWithOptions;
  final DeleteQuestion _deleteQuestion;
  final GetQuestionDetails _getQuestionDetails;
  final GetAllAdminChaptersMap _getAllAdminChaptersMap;
  final GetAllAdminMaterialsMap _getAllAdminMaterialsMap;

  QuestionBankBloc({
    required GetAdminQuestions getAdminQuestions,
    required CreateQuestionWithOptions createQuestionWithOptions,
    required UpdateQuestionWithOptions updateQuestionWithOptions,
    required DeleteQuestion deleteQuestion,
    required GetQuestionDetails getQuestionDetails,
    required GetAllAdminChaptersMap getAllAdminChaptersMap,
    required GetAllAdminMaterialsMap getAllAdminMaterialsMap,
  })  : _getAdminQuestions = getAdminQuestions,
        _createQuestionWithOptions = createQuestionWithOptions,
        _updateQuestionWithOptions = updateQuestionWithOptions,
        _deleteQuestion = deleteQuestion,
        _getQuestionDetails = getQuestionDetails,
        _getAllAdminChaptersMap = getAllAdminChaptersMap,
        _getAllAdminMaterialsMap = getAllAdminMaterialsMap,
        super(const QuestionBankState()) {
    on<LoadAdminQuestions>(_onLoadAdminQuestions);
    on<AddQuestionSubmitted>(_onAddQuestionSubmitted);
    on<LoadDropdownData>(_onLoadDropdownData);
    on<EditQuestionSubmitted>(_onEditQuestionSubmitted);
    on<DeleteQuestionPressed>(_onDeleteQuestionPressed);
    on<FetchQuestionDetailsForEdit>(_onFetchQuestionDetailsForEdit);
    on<FilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadAdminQuestions(
    LoadAdminQuestions event,
    Emitter<QuestionBankState> emit,
  ) async {
    final filterToUse = event.filter ?? state.filter;

    String? filterString;
    if (filterToUse == QuestionBankFilter.quiz) filterString = 'QUIZ';
    if (filterToUse == QuestionBankFilter.finalPractice)
      filterString = 'FINAL_PRACTICE';
    if (filterToUse == QuestionBankFilter.overallExam)
      filterString = 'OVERALL_EXAM';

    emit(state.copyWith(
        status: QuestionBankStatus.loading,
        filter: filterToUse,
        clearError: true));

    try {
      if (state.chaptersMap.isEmpty || state.materialsMap.isEmpty) {
        add(const LoadDropdownData());
      }

      final questions = await _getAdminQuestions(questionType: filterString);
      emit(state.copyWith(
          status: QuestionBankStatus.success, questions: questions));
    } catch (e) {
      emit(state.copyWith(
          status: QuestionBankStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onFilterChanged(
    FilterChanged event,
    Emitter<QuestionBankState> emit,
  ) async {
    add(LoadAdminQuestions(filter: event.filter));
  }

  Future<void> _onAddQuestionSubmitted(
    AddQuestionSubmitted event,
    Emitter<QuestionBankState> emit,
  ) async {
    emit(state.copyWith(status: QuestionBankStatus.submitting, clearError: true));
    try {
      String finalRelatedId = event.relatedId;
      if (event.questionType == 'OVERALL_EXAM') {
        finalRelatedId = '00000000-0000-0000-0000-000000000000';
      }

      await _createQuestionWithOptions(
        relatedId: finalRelatedId,
        questionType: event.questionType,
        difficulty: event.difficulty,
        questionText: event.questionText,
        imageUrl: event.imageUrl,
        options: event.options,
      );
      add(const LoadAdminQuestions());
    } catch (e) {
      emit(state.copyWith(
          status: QuestionBankStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', '')));
      emit(state.copyWith(status: QuestionBankStatus.success));
    }
  }

  Future<void> _onLoadDropdownData(
    LoadDropdownData event,
    Emitter<QuestionBankState> emit,
  ) async {
    try {
      final chaptersFuture = _getAllAdminChaptersMap();
      final materialsFuture = _getAllAdminMaterialsMap();
      final results = await Future.wait([chaptersFuture, materialsFuture]);

      final chaptersMap = results[0];
      final materialsMap = results[1];

      emit(state.copyWith(
          chaptersMap: chaptersMap, materialsMap: materialsMap));
    } catch (e) {
      emit(state.copyWith(
          status: QuestionBankStatus.failure,
          errorMessage:
              'Gagal memuat data chapter/materi: ${e.toString()}'));
    }
  }

  Future<void> _onFetchQuestionDetailsForEdit(
    FetchQuestionDetailsForEdit event,
    Emitter<QuestionBankState> emit,
  ) async {
    emit(state.copyWith(
        status: QuestionBankStatus.fetchingDetails,
        clearError: true,
        clearDetail: true));
    try {
      final detail = await _getQuestionDetails(questionId: event.questionId);
      emit(state.copyWith(
          status: QuestionBankStatus.success, questionDetail: detail));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
          status: QuestionBankStatus.failure, errorMessage: errorMessage));
      emit(state.copyWith(status: QuestionBankStatus.success));
    }
  }

  Future<void> _onEditQuestionSubmitted(
    EditQuestionSubmitted event,
    Emitter<QuestionBankState> emit,
  ) async {
    emit(state.copyWith(status: QuestionBankStatus.submitting, clearError: true));
    try {
      String finalRelatedId = event.relatedId;
      if (event.questionType == 'OVERALL_EXAM') {
        finalRelatedId = '00000000-0000-0000-0000-000000000000';
      }

      await _updateQuestionWithOptions(
        questionId: event.questionId,
        relatedId: finalRelatedId,
        questionType: event.questionType,
        difficulty: event.difficulty,
        questionText: event.questionText,
        imageUrl: event.imageUrl,
        options: event.options,
      );
      add(const LoadAdminQuestions());
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
          status: QuestionBankStatus.failure, errorMessage: errorMessage));
      emit(state.copyWith(status: QuestionBankStatus.success));
    }
  }

  Future<void> _onDeleteQuestionPressed(
    DeleteQuestionPressed event,
    Emitter<QuestionBankState> emit,
  ) async {
    emit(state.copyWith(status: QuestionBankStatus.submitting, clearError: true));
    try {
      await _deleteQuestion(questionId: event.questionId);
      add(const LoadAdminQuestions());
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
          status: QuestionBankStatus.failure, errorMessage: errorMessage));
      emit(state.copyWith(status: QuestionBankStatus.success));
    }
  }
}