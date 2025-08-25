import '../repositories/home_repository.dart';
import '../entities/home_banner.dart';
import '../entities/division.dart';

class GetHomeContent {
  final HomeRepository repository;

  GetHomeContent(this.repository);

  Future<(List<HomeBanner>, List<Division>)> call() async {
    final banners = await repository.getHomeBanners();
    final divisions = await repository.getDivisions();
    return (banners, divisions);
  }
}