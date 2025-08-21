import 'package:equatable/equatable.dart';

class Workspace extends Equatable {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final DateTime createdAt;

  const Workspace({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, description, ownerId, createdAt];
}