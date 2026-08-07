import 'dart:io';
import '../entities/himtika_kabinet.dart';
import '../entities/himtika_about.dart';
import '../entities/himtika_divisi.dart';
import '../entities/himtika_pengurus.dart';

abstract class HimtikaRepository {
  Future<HimtikaKabinet?> getActiveKabinet();
  Future<void> updateKabinet(HimtikaKabinet kabinet);

  Future<HimtikaAbout?> getAboutInfo();
  Future<void> updateAboutInfo(HimtikaAbout about);

  Future<List<HimtikaDivisi>> getDivisiList();
  Future<void> createDivisi(HimtikaDivisi divisi);
  Future<void> updateDivisi(HimtikaDivisi divisi);
  Future<void> deleteDivisi(String id);

  Future<List<HimtikaPengurus>> getPengurusByDivisi(String divisiId);
  Future<List<HimtikaPengurus>> getAllPengurus();
  Future<void> createPengurus(HimtikaPengurus pengurus);
  Future<void> updatePengurus(HimtikaPengurus pengurus);
  Future<void> deletePengurus(String id);

  Future<String> uploadImage({
    required File file,
    required String bucketName,
    required String pathPrefix,
  });
}
