part of 'overall_exam_bloc.dart';

enum OverallExamStatus { initial, loading, success, failure }

class OverallExamState extends Equatable {
  const OverallExamState({
    this.status = OverallExamStatus.initial,
    this.title,
    this.description,
  });

  final OverallExamStatus status;
  final String? title;
  final String? description;

  OverallExamState copyWith({
    OverallExamStatus? status,
    String? title,
    String? description,
  }) {
    return OverallExamState(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [status, title, description];
}