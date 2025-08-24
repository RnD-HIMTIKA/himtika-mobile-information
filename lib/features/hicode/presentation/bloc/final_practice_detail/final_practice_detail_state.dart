part of 'final_practice_detail_bloc.dart';

enum FinalExamDetailStatus { initial, loading, success, failure }

class FinalExamDetailState extends Equatable {
  const FinalExamDetailState({
    this.status = FinalExamDetailStatus.initial,
    this.title,
    this.description,
  });

  final FinalExamDetailStatus status;
  final String? title;
  final String? description;

  FinalExamDetailState copyWith({
    FinalExamDetailStatus? status,
    String? title,
    String? description,
  }) {
    return FinalExamDetailState(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [status, title, description];
}