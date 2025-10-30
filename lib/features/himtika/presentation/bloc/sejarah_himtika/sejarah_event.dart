part of 'sejarah_bloc.dart';

abstract class SejarahEvent extends Equatable {
  const SejarahEvent();
  @override
  List<Object> get props => [];
}

// Event untuk memuat data sejarah
class FetchSejarahData extends SejarahEvent {}
