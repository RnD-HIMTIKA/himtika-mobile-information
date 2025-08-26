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