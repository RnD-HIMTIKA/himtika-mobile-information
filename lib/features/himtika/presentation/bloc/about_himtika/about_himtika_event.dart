part of 'about_himtika_bloc.dart';

abstract class AboutHimtikaEvent extends Equatable {
  const AboutHimtikaEvent();

  @override
  List<Object> get props => [];
}

// Event untuk memuat semua data di halaman "Tentang HIMTIKA"
class FetchAboutData extends AboutHimtikaEvent {}
