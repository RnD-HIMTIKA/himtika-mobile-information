import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/usecases/get_events.dart';
import '../../../domain/usecases/create_event.dart';
import '../../../domain/usecases/update_event.dart';
import '../../../domain/usecases/delete_event.dart';
import '../../../domain/usecases/create_recurring_event.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEvents _getEvents;
  final CreateEvent _createEvent;
  final UpdateEvent _updateEvent;
  final DeleteEvent _deleteEvent;
  final CreateRecurringEvent _createRecurringEvent;

  DateTime? _lastLoadedStartDate;
  DateTime? _lastLoadedEndDate;

  EventBloc({
    required GetEvents getEvents,
    required CreateEvent createEvent,
    required UpdateEvent updateEvent,
    required DeleteEvent deleteEvent,
    required CreateRecurringEvent createRecurringEvent,
  })  : _getEvents = getEvents,
        _createEvent = createEvent,
        _updateEvent = updateEvent,
        _deleteEvent = deleteEvent,
        _createRecurringEvent = createRecurringEvent,
        super(const EventState()) {
    on<LoadEventsInRange>(_onLoadEventsInRange);
    on<CreateEventSubmitted>(_onCreateEventSubmitted);
    on<CreateRecurringEventSubmitted>(_onCreateRecurringEvent);
    on<UpdateEventSubmitted>(_onUpdateEventSubmitted);
    on<DeleteEventPressed>(_onDeleteEventPressed);
  }

  Future<void> _onLoadEventsInRange(
    LoadEventsInRange event,
    Emitter<EventState> emit,
  ) async {
    emit(state.copyWith(status: EventStatus.loading));
    try {
      _lastLoadedStartDate = event.startDate;
      _lastLoadedEndDate = event.endDate;
      final events = await _getEvents(event.workspaceId, event.startDate, event.endDate);
      emit(state.copyWith(
        status: EventStatus.loaded,
        events: events,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _refreshEvents(String workspaceId) {
    if (_lastLoadedStartDate != null && _lastLoadedEndDate != null) {
      add(LoadEventsInRange(
        workspaceId: workspaceId,
        startDate: _lastLoadedStartDate!,
        endDate: _lastLoadedEndDate!,
      ));
    }
  }
  
  Future<void> _onCreateEventSubmitted(
    CreateEventSubmitted event,
    Emitter<EventState> emit,
  ) async {
    try {
      await _createEvent(
        workspaceId: event.workspaceId,
        title: event.title,
        description: event.description,
        startTime: event.startTime,
        endTime: event.endTime,
      );
      _refreshEvents(event.workspaceId);
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCreateRecurringEvent(
    CreateRecurringEventSubmitted event,
    Emitter<EventState> emit,
  ) async {
    try {
      await _createRecurringEvent(
        workspaceId: event.workspaceId,
        title: event.title,
        description: event.description,
        startTime: event.startTime,
        endTime: event.endTime,
        byDay: event.byDay,
        untilDate: event.untilDate,
      );
      _refreshEvents(event.workspaceId);
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateEventSubmitted(
    UpdateEventSubmitted event,
    Emitter<EventState> emit,
  ) async {
    try {
      await _updateEvent(event.event);
      _refreshEvents(event.event.workspaceId);
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleteEventPressed(
    DeleteEventPressed event,
    Emitter<EventState> emit,
  ) async {
    try {
      await _deleteEvent(event.eventId);
      _refreshEvents(event.workspaceId);
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}