import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/hicode_chapter.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_chapters_by_material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/create_hicode_chapter.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/update_hicode_chapter.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/delete_hicode_chapter.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/reorder_hicode_chapters.dart';

part 'chapter_management_event.dart';
part 'chapter_management_state.dart';

class ChapterManagementBloc extends Bloc<ChapterManagementEvent, ChapterManagementState> {
  final GetChaptersByMaterial _getChaptersByMaterial;
  final CreateHiCodeChapter _createChapter;
  final UpdateHiCodeChapter _updateChapter;
  final DeleteHiCodeChapter _deleteChapter;
  final ReorderHiCodeChapters _reorderChapters;

  ChapterManagementBloc({
    required GetChaptersByMaterial getChaptersByMaterial,
    required CreateHiCodeChapter createChapter,
    required UpdateHiCodeChapter updateChapter,
    required DeleteHiCodeChapter deleteChapter,
    required ReorderHiCodeChapters reorderChapters,
  })  : _getChaptersByMaterial = getChaptersByMaterial,
        _createChapter = createChapter,
        _updateChapter = updateChapter,
        _deleteChapter = deleteChapter,
        _reorderChapters = reorderChapters,
        super(const ChapterManagementState()) {
    on<LoadChapters>(_onLoadChapters);
    on<AddChapterSubmitted>(_onAddChapter);
    on<UpdateChapterSubmitted>(_onUpdateChapter);
    on<DeleteChapterPressed>(_onDeleteChapter);
    on<ReorderChapters>(_onReorderChapters);
  }

  Future<void> _onLoadChapters(
    LoadChapters event,
    Emitter<ChapterManagementState> emit,
  ) async {
    emit(state.copyWith(status: ChapterManagementStatus.loading));
    try {
      final chapters = await _getChaptersByMaterial(event.materialId);
      emit(state.copyWith(
        status: ChapterManagementStatus.success,
        chapters: chapters,
        currentMaterialId: event.materialId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChapterManagementStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onAddChapter(
    AddChapterSubmitted event,
    Emitter<ChapterManagementState> emit,
  ) async {
    // Cek null atau kosong sebelum kirim ke use case
    if (event.content == null || event.content!.isEmpty) {
       emit(state.copyWith(
          status: ChapterManagementStatus.failure,
          errorMessage: 'Konten chapter tidak boleh kosong.',
       ));
       // Revert ke success agar UI tidak stuck
       emit(state.copyWith(status: ChapterManagementStatus.success));
       return;
    }

    emit(state.copyWith(status: ChapterManagementStatus.loading)); // Gunakan loading atau submitting
    try {
      final nextOrder = state.chapters.length + 1;
      await _createChapter(
        materialId: event.materialId,
        title: event.title,
        content: event.content!, // <-- Kirim List<dynamic> (non-null)
        estimatedReadTime: event.estimatedReadTime,
        order: nextOrder,
      );
      add(LoadChapters(event.materialId)); // Refresh list
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: ChapterManagementStatus.failure, errorMessage: errorMessage));
       // Revert ke success agar UI tidak stuck
       emit(state.copyWith(status: ChapterManagementStatus.success));
    }
  }

  Future<void> _onUpdateChapter(
    UpdateChapterSubmitted event,
    Emitter<ChapterManagementState> emit,
  ) async {
     // Cek null atau kosong JIKA content dikirim
    if (event.content != null && event.content!.isEmpty) {
       emit(state.copyWith(
          status: ChapterManagementStatus.failure,
          errorMessage: 'Konten chapter tidak boleh kosong jika diubah.',
       ));
       // Revert ke success agar UI tidak stuck
       emit(state.copyWith(status: ChapterManagementStatus.success));
       return;
    }

    emit(state.copyWith(status: ChapterManagementStatus.loading)); // Gunakan loading atau submitting
    try {
      await _updateChapter(
        id: event.id,
        title: event.title,
        content: event.content, // <-- Kirim List<dynamic>?
        estimatedReadTime: event.estimatedReadTime,
        order: event.order,
      );
       // Refresh list jika ada material ID tersimpan
       if (state.currentMaterialId != null) {
          add(LoadChapters(state.currentMaterialId!));
       } else {
         // Jika tidak ada material ID, setidaknya kembali ke success
         emit(state.copyWith(status: ChapterManagementStatus.success));
       }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: ChapterManagementStatus.failure, errorMessage: errorMessage));
      // Revert ke success agar UI tidak stuck
      emit(state.copyWith(status: ChapterManagementStatus.success));
    }
  }

  Future<void> _onDeleteChapter(
    DeleteChapterPressed event,
    Emitter<ChapterManagementState> emit,
  ) async {
    emit(state.copyWith(status: ChapterManagementStatus.loading));
    try {
      await _deleteChapter(id: event.id);
      add(LoadChapters(state.currentMaterialId!));
    } catch (e) {
      emit(state.copyWith(
        status: ChapterManagementStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onReorderChapters(
    ReorderChapters event,
    Emitter<ChapterManagementState> emit,
  ) async {
    try {
      await _reorderChapters(event.materialId, event.chapterIds);
      add(LoadChapters(event.materialId));
    } catch (e) {
      emit(state.copyWith(
        status: ChapterManagementStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}