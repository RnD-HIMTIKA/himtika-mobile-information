import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_question_detail.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/question_option_input.dart';
// Impor DTO / Record Type
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_chapter_map_entry.dart';

import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/create_question_with_options.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_admin_questions.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/update_question_with_options.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/delete_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_question_details.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_all_admin_chapters_map.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_all_admin_materials_map.dart';

part 'question_bank_event.dart';
part 'question_bank_state.dart';

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
    // Daftarkan semua handler
    on<LoadAdminQuestions>(_onLoadAdminQuestions);
    on<FilterChanged>(_onFilterChanged);
    on<MaterialFilterChanged>(_onMaterialFilterChanged); // <-- Handler baru
    on<ChapterFilterChanged>(_onChapterFilterChanged); // <-- Handler baru

    // Handler sisa
    on<AddQuestionSubmitted>(_onAddQuestionSubmitted);
    on<LoadDropdownData>(_onLoadDropdownData);
    on<EditQuestionSubmitted>(_onEditQuestionSubmitted);
    on<DeleteQuestionPressed>(_onDeleteQuestionPressed);
    on<FetchQuestionDetailsForEdit>(_onFetchQuestionDetailsForEdit);
  }

  Future<void> _onLoadAdminQuestions(
    LoadAdminQuestions event,
    Emitter<QuestionBankState> emit,
  ) async {
    // Ambil semua filter dari state
    final filterToUse = state.filter;
    final materialIdToUse = state.selectedMaterialId;
    final chapterIdToUse = state.selectedChapterId;

    // Tentukan filter string (untuk RPC)
    String? filterString;
    if (filterToUse == QuestionBankFilter.quiz) filterString = 'QUIZ';
    if (filterToUse == QuestionBankFilter.finalPractice)
      filterString = 'FINAL_PRACTICE';
    if (filterToUse == QuestionBankFilter.overallExam)
      filterString = 'OVERALL_EXAM';

    // --- LOGIKA BARU UNTUK relatedId ---
    String? relatedIdToUse;
    if (filterToUse == QuestionBankFilter.quiz) {
      // Jika Kuis, prioritaskan filter Chapter.
      // Jika filter Chapter null (Semua Chapter), gunakan filter Materi (bisa null juga).
      relatedIdToUse = chapterIdToUse ?? materialIdToUse;
    } else if (filterToUse == QuestionBankFilter.finalPractice) {
      // Jika Latihan Final, hanya gunakan filter Materi.
      relatedIdToUse = materialIdToUse;
    }
    // Jika 'All' atau 'OverallExam', relatedIdToUse tetap null
    // --- AKHIR LOGIKA BARU ---

    emit(state.copyWith(status: QuestionBankStatus.loading, clearError: true));

    try {
      if (state.chaptersMap.isEmpty || state.materialsMap.isEmpty) {
        add(const LoadDropdownData());
      }

      final questions = await _getAdminQuestions(
        questionType: filterString,
        relatedId: relatedIdToUse, // <-- Kirim relatedId final
      );

      emit(state.copyWith(
          status: QuestionBankStatus.success, questions: questions));
    } catch (e) {
      emit(state.copyWith(
          status: QuestionBankStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // Saat filter TIPE SOAL berubah
  Future<void> _onFilterChanged(
    FilterChanged event,
    Emitter<QuestionBankState> emit,
  ) async {
    // Reset kedua filter (Materi dan Chapter)
    emit(state.copyWith(
      filter: event.filter,
      clearMaterialFilter: true, // <-- Reset filter materi
      clearChapterFilter: true, // <-- Reset filter chapter
    ));
    add(const LoadAdminQuestions()); // Muat ulang data
  }

  // Saat filter MATERI berubah
  Future<void> _onMaterialFilterChanged(
    MaterialFilterChanged event,
    Emitter<QuestionBankState> emit,
  ) async {
    // Set Materi baru, dan RESET filter Chapter
    emit(state.copyWith(
      selectedMaterialId: event.materialId, // Set materi
      clearChapterFilter: true, // <-- Reset filter chapter
      clearMaterialFilter: event.materialId == null, // Handle jika memilih "Semua"
    ));
    add(const LoadAdminQuestions()); // Muat ulang data
  }

  // Saat filter CHAPTER berubah
  Future<void> _onChapterFilterChanged(
    ChapterFilterChanged event,
    Emitter<QuestionBankState> emit,
  ) async {
    // Set Chapter baru
    emit(state.copyWith(
      selectedChapterId: event.chapterId, // Set chapter
      clearChapterFilter: event.chapterId == null, // Handle jika memilih "Semua"
    ));
    add(const LoadAdminQuestions()); // Muat ulang data
  }

  // Handler LoadDropdownData perlu diubah untuk memakai tipe Map baru
  Future<void> _onLoadDropdownData(
    LoadDropdownData event,
    Emitter<QuestionBankState> emit,
  ) async {
    try {
      final chaptersFuture = _getAllAdminChaptersMap();
      final materialsFuture = _getAllAdminMaterialsMap();
      final results = await Future.wait([chaptersFuture, materialsFuture]);

      final chaptersMap = results[0] as Map<String, AdminChapterMapEntry>;
      final materialsMap = results[1] as Map<String, String>;

      emit(state.copyWith(
          chaptersMap: chaptersMap, materialsMap: materialsMap));
    } catch (e) {
      emit(state.copyWith(
          status: QuestionBankStatus.failure,
          errorMessage:
              'Gagal memuat data chapter/materi: ${e.toString()}'));
    }
  }

  // (Sisa handler: Add, Edit, Delete, FetchDetails tetap sama)
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