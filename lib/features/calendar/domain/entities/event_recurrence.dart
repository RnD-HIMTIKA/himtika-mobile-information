import 'package:equatable/equatable.dart';

// Entitas ini merepresentasikan aturan perulangan
class EventRecurrence extends Equatable {
  final String id;
  final String frequency; // 'WEEKLY', dll.
  final List<String> byDay; // ['MO', 'TU'], dll.
  final DateTime? untilDate;

  const EventRecurrence({
    required this.id,
    required this.frequency,
    required this.byDay,
    this.untilDate,
  });

  @override
  List<Object?> get props => [id, frequency, byDay, untilDate];
}