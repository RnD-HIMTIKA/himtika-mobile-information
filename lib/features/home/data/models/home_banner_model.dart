import '../../domain/entities/home_banner.dart';

class HomeBannerModel extends HomeBanner {
  const HomeBannerModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.order,
    super.subtitle,
    super.linkUrl,
  });

  factory HomeBannerModel.fromMap(Map<String, dynamic> map) {
    return HomeBannerModel(
      id: map['id'],
      title: map['title'],
      imageUrl: map['image_url'],
      order: map['order'],
      subtitle: map['subtitle'],
      linkUrl: map['link_url'],
    );
  }
}