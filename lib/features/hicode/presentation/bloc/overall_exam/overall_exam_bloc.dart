import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'overall_exam_event.dart';
part 'overall_exam_state.dart';

class OverallExamBloc extends Bloc<OverallExamEvent, OverallExamState> {
  OverallExamBloc() : super(const OverallExamState()) {
    on<FetchDetails>(_onFetchDetails);
  }

  void _onFetchDetails(FetchDetails event, Emitter<OverallExamState> emit) {
    emit(state.copyWith(status: OverallExamStatus.loading));
    emit(state.copyWith(
      status: OverallExamStatus.success,
      title: 'Ujian Akhir HiCode',
      description:
          'Selamat! Kamu telah menyelesaikan semua materi. Ujian akhir ini akan menguji pemahamanmu secara menyeluruh.',
    ));
  }
}