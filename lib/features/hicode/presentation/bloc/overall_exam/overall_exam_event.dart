part of 'overall_exam_bloc.dart';

abstract class OverallExamEvent extends Equatable {
  const OverallExamEvent();
  @override
  List<Object> get props => [];
}

class FetchDetails extends OverallExamEvent {}