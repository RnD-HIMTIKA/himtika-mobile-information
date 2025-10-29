import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/create_question_with_options.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_admin_questions.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/update_question_with_options.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/delete_question.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_question_details.dart';
import 'question_bank_event.dart';
import 'question_bank_state.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_all_admin_chapters_map.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_all_admin_materials_map.dart';

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
  }

  Future<void> _onLoadAdminQuestions(
    LoadAdminQuestions event,
    Emitter<QuestionBankState> emit,
  ) async {
    // Emit loading hanya jika daftar soal masih kosong (untuk refresh halus)
    if (state.questions.isEmpty) {
       emit(state.copyWith(status: QuestionBankStatus.loading, clearError: true));
    } else {
       // Jika sudah ada data, setidaknya hapus error lama
       emit(state.copyWith(clearError: true));
    }

    try {
      add(const LoadDropdownData()); // <<< Tambahkan ini
      final questions = await _getAdminQuestions();
      emit(state.copyWith(status: QuestionBankStatus.success, questions: questions));
    } catch (e) {
      emit(state.copyWith(status: QuestionBankStatus.failure, errorMessage: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAddQuestionSubmitted(
    AddQuestionSubmitted event,
    Emitter<QuestionBankState> emit,
  ) async {
    // Emit status submitting untuk menampilkan loading di dialog/tombol
    emit(state.copyWith(status: QuestionBankStatus.submitting, clearError: true));
    try {
      // Tentukan related_id berdasarkan tipe soal (sementara pakai yang dikirim)
      // TODO: Perbaiki logika related_id jika OVERALL_EXAM nanti
      String finalRelatedId = event.relatedId;
      if (event.questionType == 'OVERALL_EXAM') {
         // Untuk OVERALL_EXAM, related_id mungkin tidak diperlukan atau bisa diisi UUID null/default
         // Anda bisa set UUID spesifik atau biarkan kosong/null sesuai definisi RPC
         // Contoh: Gunakan UUID kosong jika RPC bisa handle null/default
         // finalRelatedId = '00000000-0000-0000-0000-000000000000'; // Sesuaikan!
      }


      await _createQuestionWithOptions(
        relatedId: finalRelatedId,
        questionType: event.questionType,
        difficulty: event.difficulty,
        questionText: event.questionText,
        imageUrl: event.imageUrl,
        options: event.options,
      );
      // Kembali ke status success dan refresh daftar soal
      add(const LoadAdminQuestions());
    } catch (e) {
      // Jika gagal, kembali ke status failure dan tampilkan error
      emit(state.copyWith(status: QuestionBankStatus.failure, errorMessage: e.toString().replaceFirst('Exception: ', '')));
       // Kembali ke success agar UI utama tidak stuck di loading/error state setelah dialog ditutup
      emit(state.copyWith(status: QuestionBankStatus.success));
    }
  }

  Future<void> _onLoadDropdownData(
    LoadDropdownData event,
    Emitter<QuestionBankState> emit,
  ) async {
     // Tidak perlu emit loading karena biasanya dipanggil bersamaan dengan load questions
     try {
        // Ambil data chapter dan materi secara paralel
        final chaptersFuture = _getAllAdminChaptersMap();
        final materialsFuture = _getAllAdminMaterialsMap();
        final results = await Future.wait([chaptersFuture, materialsFuture]);

        final chaptersMap = results[0] as Map<String, String>;
        final materialsMap = results[1] as Map<String, String>;

        emit(state.copyWith(chaptersMap: chaptersMap, materialsMap: materialsMap));

     } catch (e) {
        // Tangani error jika gagal load dropdown (mungkin tampilkan pesan di state utama)
        emit(state.copyWith(status: QuestionBankStatus.failure, errorMessage: 'Gagal memuat data chapter/materi: ${e.toString()}'));
     }
  }

  Future<void> _onFetchQuestionDetailsForEdit(
    FetchQuestionDetailsForEdit event,
    Emitter<QuestionBankState> emit,
  ) async {
    emit(state.copyWith(status: QuestionBankStatus.fetchingDetails, clearError: true, clearDetail: true));
    try {
      // Panggil use case untuk get detail
      final detail = await _getQuestionDetails(questionId: event.questionId);
      // Simpan detail di state dan kembali ke status success
      emit(state.copyWith(status: QuestionBankStatus.success, questionDetail: detail));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: QuestionBankStatus.failure, errorMessage: errorMessage));
      // Revert ke success agar UI utama tidak stuck
      emit(state.copyWith(status: QuestionBankStatus.success));
    }
  }

  Future<void> _onEditQuestionSubmitted(
    EditQuestionSubmitted event,
    Emitter<QuestionBankState> emit,
  ) async {
    emit(state.copyWith(status: QuestionBankStatus.submitting, clearError: true));
    try {
      // Tentukan finalRelatedId (sama seperti di add)
      String finalRelatedId = event.relatedId;
      if (event.questionType == 'OVERALL_EXAM') {
         finalRelatedId = '00000000-0000-0000-0000-000000000000'; // Atau null
      }

      await _updateQuestionWithOptions(
        questionId: event.questionId, // <-- Kirim ID soal
        relatedId: finalRelatedId,
        questionType: event.questionType,
        difficulty: event.difficulty,
        questionText: event.questionText,
        imageUrl: event.imageUrl,
        options: event.options,
      );
      // Refresh daftar soal setelah berhasil
      add(const LoadAdminQuestions());
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: QuestionBankStatus.failure, errorMessage: errorMessage));
      // Revert ke success agar UI utama tidak stuck
      emit(state.copyWith(status: QuestionBankStatus.success));
    }
  }

  Future<void> _onDeleteQuestionPressed(
    DeleteQuestionPressed event,
    Emitter<QuestionBankState> emit,
  ) async {
    // Bisa langsung emit success dan hapus dari list lokal dulu untuk UX cepat,
    // atau emit loading lalu refresh setelah delete berhasil. Kita pilih loading.
    emit(state.copyWith(status: QuestionBankStatus.submitting, clearError: true));
    try {
      await _deleteQuestion(questionId: event.questionId);
      // Refresh daftar soal setelah berhasil
      add(const LoadAdminQuestions());
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: QuestionBankStatus.failure, errorMessage: errorMessage));
      // Revert ke success agar UI utama tidak stuck
      emit(state.copyWith(status: QuestionBankStatus.success));
    }
  }
}