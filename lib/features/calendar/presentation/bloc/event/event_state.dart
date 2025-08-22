part of 'event_bloc.dart';

enum EventStatus { initial, loading, loaded, failure }

class EventState extends Equatable {
  final EventStatus status;
  final List<Event> events;
  final String? errorMessage;

  const EventState({
    this.status = EventStatus.initial,
    this.events = const [],
    this.errorMessage,
  });

  EventState copyWith({
    EventStatus? status,
    List<Event>? events,
    String? errorMessage,
  }) {
    return EventState(
      status: status ?? this.status,
      events: events ?? this.events,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, events, errorMessage];
}