part of 'final_practice_detail_bloc.dart';

abstract class FinalExamDetailEvent extends Equatable {
  const FinalExamDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchFinalExamDetails extends FinalExamDetailEvent {
  final String materialName;
  const FetchFinalExamDetails({required this.materialName});
  @override
  List<Object> get props => [materialName];
}