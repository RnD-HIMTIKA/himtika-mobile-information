import 'package:equatable/equatable.dart';

class HomeBanner extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final int order;
  final String? subtitle;
  final String? linkUrl;

  const HomeBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.order,
    this.subtitle,
    this.linkUrl,
  });

  @override
  List<Object?> get props => [id, title, imageUrl, order, subtitle, linkUrl];
}