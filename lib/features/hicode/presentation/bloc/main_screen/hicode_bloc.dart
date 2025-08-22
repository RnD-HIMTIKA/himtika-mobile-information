import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'hicode_event.dart';
part 'hicode_state.dart';

class HicodeBloc extends Bloc<HicodeEvent, HicodeState> {
  HicodeBloc() : super(const HicodeState()) {
    on<HicodeDataFetched>(_onHicodeDataFetched);
  }

  void _onHicodeDataFetched(HicodeDataFetched event, Emitter<HicodeState> emit) {
    emit(state.copyWith(status: HicodeStatus.loading));

    // --- DATA DUMMY DIBUAT LANGSUNG DI SINI ---
    final dummyCategories = [
      {'name': 'HTML', 'iconPath': 'src/features/hicode/icon/html.png'},
      {'name': 'CSS', 'iconPath': 'src/features/hicode/icon/css.png'},
      {'name': 'JavaScript', 'iconPath': 'src/features/hicode/icon/js.png'},
      {'name': 'C++', 'iconPath': 'src/features/hicode/icon/cpp.png'},
    ];

    final dummyMaterials = [
      {
        'title': 'Materi 1 - HTML',
        'iconPath': 'src/features/hicode/images/html.png',
        'chapterProgress': '1/8 Chapter',
        'exerciseCount': 10
      },
      {
        'title': 'Materi 2 - CSS',
        'iconPath': 'src/features/hicode/images/css.png',
        'chapterProgress': '1/8 Chapter',
        'exerciseCount': 10
      },
      {
        'title': 'Materi 3 - JavaScript',
        'iconPath': 'src/features/hicode/images/js.png',
        'chapterProgress': '1/8 Chapter',
        'exerciseCount': 10
      },
      {
        'title': 'Materi 4 - C++',
        'iconPath': 'src/features/hicode/images/cpp.png',
        'chapterProgress': '1/8 Chapter',
        'exerciseCount': 10
      },
    ];

    emit(state.copyWith(
      status: HicodeStatus.success,
      categories: dummyCategories,
      materials: dummyMaterials,
      isExamReady: true,
    ));
  }
} 