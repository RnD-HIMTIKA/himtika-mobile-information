import 'package:equatable/equatable.dart';

abstract class LecturerEvent extends Equatable {
  const LecturerEvent();

  @override
  List<Object> get props => [];
}

// Event saat user klik tombol filter
class LecturerCategoryChanged extends LecturerEvent {
  final String category; // Misal: "Informatika"

  const LecturerCategoryChanged(this.category);

  @override
  List<Object> get props => [category];
}

// Event saat user mengetik di search bar
class LecturerSearchChanged extends LecturerEvent {
  final String query; // Teks yang diketik
  const LecturerSearchChanged(this.query);

  @override
  List<Object> get props => [query];
}
