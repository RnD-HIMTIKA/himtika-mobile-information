import 'package:equatable/equatable.dart';

class HiCodeChapter extends Equatable {
  final String id;
  final String materialId;
  final String title;
  final List<dynamic>? content;
  final int? estimatedReadTime;
  final int order;
  final DateTime createdAt;

  const HiCodeChapter({
    required this.id,
    required this.materialId,
    required this.title,
    this.content,
    this.estimatedReadTime,
    required this.order,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    materialId,
    title,
    content,
    estimatedReadTime,
    order,
    createdAt,
  ];
}