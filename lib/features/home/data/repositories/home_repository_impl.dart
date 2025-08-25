import '../../domain/entities/home_banner.dart';
import '../../domain/entities/division.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_banner_model.dart';
import '../models/division_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource remoteDatasource;

  HomeRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<HomeBanner>> getHomeBanners() async {
    final data = await remoteDatasource.getBanners();
    return data.map((map) => HomeBannerModel.fromMap(map)).toList();
  }

  @override
  Future<List<Division>> getDivisions() async {
    final data = await remoteDatasource.getDivisions();
    return data.map((map) => DivisionModel.fromMap(map)).toList();
  }
}