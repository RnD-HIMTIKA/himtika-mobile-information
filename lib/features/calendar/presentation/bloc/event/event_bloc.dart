import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/usecases/get_events.dart';
import '../../../domain/usecases/create_event.dart';
import '../../../domain/usecases/update_event.dart';
import '../../../domain/usecases/delete_event.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEvents _getEvents;
  final CreateEvent _createEvent;
  final UpdateEvent _updateEvent;
  final DeleteEvent _deleteEvent;

  EventBloc({
    required GetEvents getEvents,
    required CreateEvent createEvent,
    required UpdateEvent updateEvent, // Tambahkan
    required DeleteEvent deleteEvent, // Tambahkan
  })  : _getEvents = getEvents,
        _createEvent = createEvent,
        _updateEvent = updateEvent,
        _deleteEvent = deleteEvent,
        super(const EventState()) {
    on<LoadEvents>(_onLoadEvents);
    on<CreateEventSubmitted>(_onCreateEventSubmitted);
    on<UpdateEventSubmitted>(_onUpdateEventSubmitted); // Daftarkan
    on<DeleteEventPressed>(_onDeleteEventPressed); // Daftarkan
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

  Future<void> _onUpdateEventSubmitted(
    UpdateEventSubmitted event,
    Emitter<EventState> emit,
  ) async {
    try {
      await _updateEvent(event.event);
      add(LoadEvents(event.event.workspaceId)); // Refresh
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
      add(LoadEvents(event.workspaceId)); // Refresh
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}