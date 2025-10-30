part of 'kabinet_bloc.dart';

abstract class KabinetEvent extends Equatable {
  const KabinetEvent();
  @override
  List<Object> get props => [];
}

class FetchKabinetData extends KabinetEvent {}
