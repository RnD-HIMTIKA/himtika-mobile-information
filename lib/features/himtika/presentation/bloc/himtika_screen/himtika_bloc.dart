import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/himtika_repository.dart';

part 'himtika_event.dart';
part 'himtika_state.dart';

class HimtikaBloc extends Bloc<HimtikaEvent, HimtikaState> {
  final HimtikaRepository? repository;

  HimtikaBloc({this.repository}) : super(const HimtikaState()) {
    on<FetchHimtikaData>(_onFetchHimtikaData);
  }

  Future<void> _onFetchHimtikaData(
      FetchHimtikaData event, Emitter<HimtikaState> emit) async {
    emit(state.copyWith(status: HimtikaStatus.loading));

    String kabinetName = 'SINERGIS';
    String kabinetTagline =
        'Sinergi, Inovatif, Eksplorasi, Responsif, Generalis, Sistematis';
    String kabinetLogoPath = 'src/features/himtika/images/kabinet.png';

    try {
      if (repository != null) {
        final activeKabinet = await repository!.getActiveKabinet();
        if (activeKabinet != null) {
          if (activeKabinet.namaKabinet.isNotEmpty) {
            kabinetName = activeKabinet.namaKabinet;
          }
          if (activeKabinet.tagline != null && activeKabinet.tagline!.isNotEmpty) {
            kabinetTagline = activeKabinet.tagline!;
          } else if (activeKabinet.nilaiKabinet.isNotEmpty) {
            final titles = activeKabinet.nilaiKabinet
                .map((e) => e['title'] ?? '')
                .where((t) => t.isNotEmpty)
                .toList();
            if (titles.isNotEmpty) {
              kabinetTagline = titles.join(', ');
            }
          }
          if (activeKabinet.logoUrl != null && activeKabinet.logoUrl!.isNotEmpty) {
            kabinetLogoPath = activeKabinet.logoUrl!;
          }
        }
      }
    } catch (_) {
      // Fallback to default
    }

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
      kabinetName: kabinetName,
      kabinetTagline: kabinetTagline,
      kabinetLogoPath: kabinetLogoPath,
    ));
  }
}