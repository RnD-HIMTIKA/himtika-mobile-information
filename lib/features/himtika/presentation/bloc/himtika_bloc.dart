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
    final dummyParts = [
      {
        'imagePath': 'src/features/himtika/images/card_divisi.png',
      },
      {
        'imagePath': 'src/features/himtika/images/card_divisi.png',
      },
      // Tambahkan bagian lain di sini
    ];

    emit(state.copyWith(
      status: HimtikaStatus.success,
      importantParts: dummyParts,
    ));
  }
}