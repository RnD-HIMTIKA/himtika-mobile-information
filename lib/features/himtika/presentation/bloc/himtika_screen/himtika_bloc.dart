import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'himtika_event.dart';
part 'himtika_state.dart';

class HimtikaBloc extends Bloc<HimtikaEvent, HimtikaState> {
  HimtikaBloc() : super(const HimtikaState()) {
    on<FetchHimtikaData>(_onFetchHimtikaData);
  }

  void _onFetchHimtikaData(
      FetchHimtikaData event, Emitter<HimtikaState> emit) {
    emit(state.copyWith(status: HimtikaStatus.loading));

    // Data Dummy untuk "Bagian Penting"
    final dummyImportantParts = [
      {
        'imagePath': 'src/features/himtika/divisi/sc/sc.png',
        'title': 'Steering Committee',
      },
      {
        'imagePath': 'src/features/himtika/divisi/internal/internal.png',
        'title': 'Divisi Internal',
      },
      {
        'imagePath': 'src/features/himtika/divisi/rnd/rnd.png',
        'title': 'Divisi RnD',
      },
      {
        'imagePath': 'src/features/himtika/divisi/relasi/relasi.png',
        'title': 'Divisi Relasi',
      },
      {
        'imagePath': 'src/features/himtika/divisi/edukasi/edukasi.png',
        'title': 'Divisi Edukasi',
      },
      {
        'imagePath': 'src/features/himtika/divisi/infokom/infokom.png',
        'title': 'Divisi Infokom',
      },
    ];

    emit(state.copyWith(
      status: HimtikaStatus.success,
      importantParts: dummyImportantParts,
    ));
  }
}