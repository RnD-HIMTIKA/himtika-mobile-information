part of 'event_bloc.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();
  @override
  List<Object?> get props => [];
}

// Event untuk memuat semua event dari workspace tertentu
class LoadEvents extends EventEvent {
  final String workspaceId;
  const LoadEvents(this.workspaceId);
  @override
  List<Object> get props => [workspaceId];
}

// Event saat pengguna menekan tombol "Buat Event"
class CreateEventSubmitted extends EventEvent {
  final String workspaceId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;

  const CreateEventSubmitted({
    required this.workspaceId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [workspaceId, title, description, startTime, endTime];
}