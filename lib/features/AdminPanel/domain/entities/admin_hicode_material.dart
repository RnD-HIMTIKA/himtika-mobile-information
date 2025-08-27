import 'package:equatable/equatable.dart';

class AdminHiCodeMaterial extends Equatable {
  final String id;
  final String title;
  final String? categoryName;
  final int chapterCount;

  const AdminHiCodeMaterial({
    required this.id,
    required this.title,
    this.categoryName,
    required this.chapterCount,
  });

  @override
  List<Object?> get props => [id, title, categoryName, chapterCount];
}