import 'package:equatable/equatable.dart';

class HiCodeChapter extends Equatable {
  final String id;
  final String title;
  final String details; // Contoh: "2 Soal Kuis"
  final bool isCompleted;
  final bool isLocked;

  const HiCodeChapter({
    required this.id,
    required this.title,
    required this.details,
    required this.isCompleted,
    required this.isLocked,
  });

  @override
  List<Object?> get props => [id, title, details, isCompleted, isLocked];
}