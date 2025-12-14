part of 'proker_bloc.dart';

abstract class ProkerEvent extends Equatable {
  const ProkerEvent();

  @override
  List<Object> get props => [];
}

class FetchProkerData extends ProkerEvent {}

class ChangeProkerCategory extends ProkerEvent {
  final String category;
  const ChangeProkerCategory(this.category);

  @override
  List<Object> get props => [category];
}
