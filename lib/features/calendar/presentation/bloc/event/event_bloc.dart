import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/usecases/get_events.dart';
import '../../../domain/usecases/create_event.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEvents _getEvents;
  final CreateEvent _createEvent;

  EventBloc({
    required GetEvents getEvents,
    required CreateEvent createEvent,
  })  : _getEvents = getEvents,
        _createEvent = createEvent,
        super(const EventState()) {
    on<LoadEvents>(_onLoadEvents);
    on<CreateEventSubmitted>(_onCreateEventSubmitted);
  }

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(state.copyWith(status: EventStatus.loading));
    try {
      final events = await _getEvents(event.workspaceId);
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
      // Panggil event untuk memuat ulang daftar event
      add(LoadEvents(event.workspaceId));
    } catch (e) {
      // Jika gagal, emit state failure dengan pesan error
      emit(state.copyWith(
        status: EventStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}