import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_material.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/get_main_screen_data.dart';

part 'main_screen_event.dart';
part 'main_screen_state.dart';

class HicodeBloc extends Bloc<HicodeEvent, HicodeState> {
  final GetMainScreenData _getMainScreenData;

  HicodeBloc({required GetMainScreenData getMainScreenData})
      : _getMainScreenData = getMainScreenData,
        super(const HicodeState()) {
    on<HicodeDataFetched>(_onHicodeDataFetched);
  }

  Future<void> _onHicodeDataFetched(
      HicodeDataFetched event, Emitter<HicodeState> emit) async {
    emit(state.copyWith(status: HicodeStatus.loading));
    try {
      final (categories, materials, isExamReady) = await _getMainScreenData();
      emit(state.copyWith(
        status: HicodeStatus.success,
        categories: categories,
        materials: materials,
        isExamReady: isExamReady,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HicodeStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}