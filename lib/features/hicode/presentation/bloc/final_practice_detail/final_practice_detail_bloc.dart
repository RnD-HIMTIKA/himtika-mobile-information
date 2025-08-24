import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'final_practice_detail_event.dart';
part 'final_practice_detail_state.dart';

class FinalExamDetailBloc
    extends Bloc<FinalExamDetailEvent, FinalExamDetailState> {
  FinalExamDetailBloc() : super(const FinalExamDetailState()) {
    // Pastikan event handler ini terdaftar
    on<FetchFinalExamDetails>(_onFetchFinalExamDetails);
  }

  // Pastikan method ini ada dan benar
  void _onFetchFinalExamDetails(
      FetchFinalExamDetails event, Emitter<FinalExamDetailState> emit) {
    // 1. Kirim state 'loading'
    emit(state.copyWith(status: FinalExamDetailStatus.loading));

    // 2. Siapkan data
    final title = 'Latihan Final - ${event.materialName}';
    final description =
        'Selamat datang di Latihan Soal Final untuk topik ${event.materialName}. Ini adalah langkah akhir sebelum kamu melanjutkan ke topik berikutnya.';

    // 3. Kirim state 'success' dengan data yang sudah disiapkan
    emit(state.copyWith(
      status: FinalExamDetailStatus.success,
      title: title,
      description: description,
    ));
  }
}