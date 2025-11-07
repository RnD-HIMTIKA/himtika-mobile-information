import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

// --- EVENT ---
abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();
  @override
  List<Object> get props => [];
}

class StartListening extends ConnectivityEvent {}

class ConnectivityChanged extends ConnectivityEvent {
  final ConnectivityResult result;
  const ConnectivityChanged(this.result);
  @override
  List<Object> get props => [result];
}

// --- STATE ---
class ConnectivityState extends Equatable {
  final ConnectivityResult result;
  const ConnectivityState(this.result);
  
  bool get isOnline => result != ConnectivityResult.none;

  @override
  List<Object> get props => [result];
}

// --- BLOC ---
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  StreamSubscription? _connectivitySubscription;

  ConnectivityBloc() : super(const ConnectivityState(ConnectivityResult.none)) {
    on<StartListening>(_onStartListening);
    on<ConnectivityChanged>(_onConnectivityChanged);
  }

  void _onStartListening(StartListening event, Emitter<ConnectivityState> emit) {
    _connectivitySubscription?.cancel();
    // Cek status awal saat mulai mendengarkan
    Connectivity().checkConnectivity().then((initialResult) {
      add(ConnectivityChanged(initialResult));
    });
    // Dengarkan perubahan
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      add(ConnectivityChanged(result));
    });
  }

  void _onConnectivityChanged(ConnectivityChanged event, Emitter<ConnectivityState> emit) {
    emit(ConnectivityState(event.result));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}