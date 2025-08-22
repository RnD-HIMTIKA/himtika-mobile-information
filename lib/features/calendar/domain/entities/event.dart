import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String workspaceId;
  final String createdBy;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.workspaceId,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        createdBy,
        title,
        description,
        startTime,
        endTime,
        createdAt,
      ];
}