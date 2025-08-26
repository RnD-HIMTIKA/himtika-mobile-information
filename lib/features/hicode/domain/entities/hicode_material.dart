import 'package:equatable/equatable.dart';

class HiCodeMaterial extends Equatable {
  final String id;
  final String title;
  final String? imageUrl;
  final String? borderColor;
  final int totalChapters;
  final int completedChapters;

  const HiCodeMaterial({
    required this.id,
    required this.title,
    this.imageUrl,
    this.borderColor,
    required this.totalChapters,
    required this.completedChapters,
  });

  @override
  List<Object?> get props => [id, title, imageUrl, borderColor, totalChapters, completedChapters];
}