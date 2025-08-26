part of 'himtika_bloc.dart';

abstract class HimtikaEvent extends Equatable {
  const HimtikaEvent();
  @override
  List<Object> get props => [];
}

class FetchHimtikaData extends HimtikaEvent {}