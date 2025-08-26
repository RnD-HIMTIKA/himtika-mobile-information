part of 'main_screen_bloc.dart';

abstract class HicodeEvent extends Equatable {
  const HicodeEvent();
  @override
  List<Object> get props => [];
}

class HicodeDataFetched extends HicodeEvent {}