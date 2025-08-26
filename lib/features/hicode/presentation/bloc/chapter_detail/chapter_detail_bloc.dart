import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_chapter.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/get_chapter_list_data.dart';

part 'chapter_detail_event.dart';
part 'chapter_detail_state.dart';

class MaterialDetailBloc
    extends Bloc<MaterialDetailEvent, MaterialDetailState> {
  final GetChapterListData _getChapterListData;

  MaterialDetailBloc({required GetChapterListData getChapterListData})
      : _getChapterListData = getChapterListData,
        super(const MaterialDetailState()) {
    on<FetchDetailData>(_onFetchDetailData);
  }

  Future<void> _onFetchDetailData(
      FetchDetailData event, Emitter<MaterialDetailState> emit) async {
    emit(state.copyWith(status: MaterialDetailStatus.loading));
    try {
      final (title, description, iconPath, chapters) =
          await _getChapterListData(event.materialId);
      emit(state.copyWith(
        status: MaterialDetailStatus.success,
        title: title,
        description: description,
        materialIconPath: iconPath,
        chapters: chapters,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MaterialDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}