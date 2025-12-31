import 'package:flutter_bloc/flutter_bloc.dart';
import 'lecturer_event.dart';
import 'lecturer_state.dart';
import '../../data/models/lecturer_model.dart';

export 'lecturer_event.dart';
export 'lecturer_state.dart';

class LecturerBloc extends Bloc<LecturerEvent, LecturerState> {
  // Data Dummy (Nanti ini diganti ambil dari API/Repository)
  final List<Lecturer> _allLecturers = [
    Lecturer(
      name: "Prof. Ir. Soekarno", 
      role: "Dosen Informatika", 
      category: "Informatika",
      nidn: "0412345678",
      phone: "+62 812 3456 7890",
      email: "soekarno@unsika.ac.id",
      photoUrl: "src/features/hilecturer/icons/header.png",
    ),
    Lecturer(
      name: "Prof. Ir. Soekarmo", 
      role: "Dosen Sistem Informasi", 
      category: "Sistem Informasi",
      nidn: "0412345679",
      phone: "+62 812 3456 7891",
      email: "soekarmo@unsika.ac.id",
      photoUrl: "src/features/hilecturer/icons/header.png",
    ),
    Lecturer(
      name: "Prof. Ir. Soekarjo", 
      role: "Dosen Informatika", 
      category: "Informatika",
      nidn: "0412345680",
      phone: "+62 812 3456 7892",
      email: "soekarjo@unsika.ac.id",
      photoUrl: "src/features/hilecturer/icons/header.png",
    ),
    Lecturer(
      name: "Prof. Ir. Soekarjo", 
      role: "Dosen Informatika", 
      category: "Informatika",
      nidn: "0412345680",
      phone: "+62 812 3456 7892",
      email: "soekarjo@unsika.ac.id",
      photoUrl: "src/features/hilecturer/icons/header.png",
    ),
    Lecturer(
      name: "Dr. Hatta", 
      role: "Dosen Sistem Informasi", 
      category: "Sistem Informasi",
      nidn: "0412345681",
      phone: "+62 812 3456 7893",
      email: "hatta@unsika.ac.id",
      photoUrl: "src/features/hilecturer/icons/header.png",
    ),
    Lecturer(
      name: "Dr. Hatta", 
      role: "Dosen Sistem Informasi", 
      category: "Sistem Informasi",
      nidn: "0412345681",
      phone: "+62 812 3456 7893",
      email: "hatta@unsika.ac.id",
      photoUrl: "src/features/hilecturer/icons/header.png", 
    ),
     Lecturer(
      name: "Ir. Juanda, M.Kom", 
      role: "Dosen Informatika", 
      category: "Informatika",
      nidn: "0412345682",
      phone: "+62 812 3456 7894",
      email: "juanda@unsika.ac.id",
      photoUrl: "src/features/hilecturer/icons/header.png",
    ),
     Lecturer(
      name: "Ir. Ferdi Yansah, M.Kom", 
      role: "Dosen Sistem Informasi", 
      category: "Sistem Informasi",
      nidn: "0412345683",
      phone: "+62 812 3456 7895",
      email: "ferdi@unsika.ac.id",
      photoUrl: "src/features/hilecturer/icons/header.png",
    ),
  ];

  LecturerBloc() : super(const LecturerState()) {
    // 1. Saat inisialisasi, tampilkan SEMUA data
    on<LecturerCategoryChanged>(_onCategoryChanged);

    // 2. Saat user mengetik di search bar
    on<LecturerSearchChanged>(_onSearchChanged);

    // Trigger event pertama kali biar list gak kosong pas dibuka
    add(const LecturerCategoryChanged("Semua"));
  }

  // 1. Logic Saat Kategori Diganti
  void _onCategoryChanged(
      LecturerCategoryChanged event, Emitter<LecturerState> emit) {
    // Update state kategori dulu
    final newState = state.copyWith(selectedCategory: event.category);
    // Lalu jalankan filter gabungan
    _applyFilter(emit, newState);
  }

  // 2. Logic Saat Search Ngetik
  void _onSearchChanged(
      LecturerSearchChanged event, Emitter<LecturerState> emit) {
    // Update state query search dulu
    final newState = state.copyWith(searchQuery: event.query);
    // Lalu jalankan filter gabungan
    _applyFilter(emit, newState);
  }

  // 3. FUNGSI FILTER PUSAT (Gabungan)
  void _applyFilter(Emitter<LecturerState> emit, LecturerState currentState) {
    List<Lecturer> result = _allLecturers;

    // A. Filter Kategori Dulu
    if (currentState.selectedCategory != "Semua") {
      result = result
          .where((l) => l.category == currentState.selectedCategory)
          .toList();
    }

    // B. Lanjut Filter Search (Kalau ada teks)
    if (currentState.searchQuery.isNotEmpty) {
      final query =
          currentState.searchQuery.toLowerCase(); // Biar gak case sensitive
      result = result.where((l) {
        return l.name.toLowerCase().contains(query); // Cek nama dosen
      }).toList();
    }

    // Update Hasil Akhir
    emit(currentState.copyWith(filteredLecturers: result));
  }
}
