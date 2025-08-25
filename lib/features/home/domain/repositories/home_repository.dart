import '../entities/home_banner.dart';
import '../entities/division.dart';

abstract class HomeRepository {
  Future<List<HomeBanner>> getHomeBanners();
  Future<List<Division>> getDivisions();
}