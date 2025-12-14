import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
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
      // Load bytes dari asset
      final byteData = await rootBundle.load(
          'src/features/himtika/gd/grand_design.pdf'); 

      // Dapatkan temp dir
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/grand_design.pdf';

      // Simpan ke file temp
      final file = File(filePath);
      await file.writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );

      // pdfPath sekarang adalah local file path (bisa tambah 'file://$filePath' kalau error persist)
      final pdfPath = filePath;
      final coverPath =
          'src/features/himtika/gd/cover.jpg'; // Cover tetep asset

      emit(GrandDesignLoaded(pdfPath, coverPath));
    } catch (e) {
      emit(GrandDesignError(e.toString()));
    }
  }
}
