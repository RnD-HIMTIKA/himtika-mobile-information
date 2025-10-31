import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class ChangeTab extends HomeEvent {
  final int index;
  const ChangeTab(this.index);

  @override
  List<Object?> get props => [index];
}
