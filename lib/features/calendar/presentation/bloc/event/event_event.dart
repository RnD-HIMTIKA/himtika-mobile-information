part of 'event_bloc.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();
  @override
  List<Object?> get props => [];
}

// PERBAIKAN: Ganti nama LoadEvents menjadi LoadEventsInRange
class LoadEventsInRange extends EventEvent {
  final String workspaceId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadEventsInRange({
    required this.workspaceId,
    required this.startDate,
    required this.endDate,
  });
  @override
  List<Object> get props => [workspaceId, startDate, endDate];
}

class CreateEventSubmitted extends EventEvent {
  final String workspaceId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final List<int>? reminderMinutesBefore;

  const CreateEventSubmitted({
    required this.workspaceId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.reminderMinutesBefore,
  });
  
  @override
  List<Object?> get props => [workspaceId, title, description, startTime, endTime];
}

// Event BARU untuk membuat event berulang
class CreateRecurringEventSubmitted extends EventEvent {
  final String workspaceId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> byDay;
  final DateTime untilDate;
  final List<int>? reminderMinutesBefore;

  const CreateRecurringEventSubmitted({
    required this.workspaceId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.byDay,
    required this.untilDate,
    this.reminderMinutesBefore,
  });
}

class UpdateEventSubmitted extends EventEvent {
  final Event event;
  const UpdateEventSubmitted(this.event);
  @override
  List<Object> get props => [event];
}

class DeleteEventPressed extends EventEvent {
  final String eventId;
  final String workspaceId;
  const DeleteEventPressed(this.eventId, this.workspaceId);
  @override
  List<Object> get props => [eventId, workspaceId];
}