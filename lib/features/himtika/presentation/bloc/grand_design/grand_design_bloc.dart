import 'package:flutter_bloc/flutter_bloc.dart';
import 'grand_design_event.dart';
import 'grand_design_state.dart';

export 'grand_design_event.dart';
export 'grand_design_state.dart';

class GrandDesignBloc extends Bloc<GrandDesignEvent, GrandDesignState> {
  GrandDesignBloc() : super(GrandDesignLoading()) {
    on<LoadGrandDesignBook>(_onLoad);
  }

  void _onLoad(
    LoadGrandDesignBook event,
    Emitter<GrandDesignState> emit,
  ) async {
    try {
      // 🔹 Dinamis
      final pages = List.generate(
        90,
        (i) => 'src/features/himtika/gd/page_${i + 1}.jpg',
      );

      emit(GrandDesignLoaded(pages));
    } catch (e) {
      emit(GrandDesignError(e.toString()));
    }
  }
}
