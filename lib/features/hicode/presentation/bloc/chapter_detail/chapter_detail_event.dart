part of 'chapter_detail_bloc.dart';

abstract class MaterialDetailEvent extends Equatable {
  const MaterialDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchDetailData extends MaterialDetailEvent {
  final String materialId;
  const FetchDetailData({required this.materialId});
  @override
  List<Object> get props => [materialId];
}

// --- TAMBAHKAN EVENT BARU INI ---
class SearchQueryChanged extends MaterialDetailEvent {
  final String query;
  const SearchQueryChanged({required this.query});
  @override
  List<Object> get props => [query];
}