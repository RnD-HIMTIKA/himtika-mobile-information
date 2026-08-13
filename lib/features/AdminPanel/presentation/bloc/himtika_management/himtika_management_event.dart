import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../../himtika/domain/entities/himtika_kabinet.dart';
import '../../../../himtika/domain/entities/himtika_about.dart';
import '../../../../himtika/domain/entities/himtika_divisi.dart';
import '../../../../himtika/domain/entities/himtika_pengurus.dart';

abstract class HimtikaManagementEvent extends Equatable {
  const HimtikaManagementEvent();

  @override
  List<Object?> get props => [];
}

class FetchHimtikaAdminData extends HimtikaManagementEvent {
  const FetchHimtikaAdminData();
}

class UpdateKabinetEvent extends HimtikaManagementEvent {
  final HimtikaKabinet kabinet;
  final File? logoFile;

  const UpdateKabinetEvent({
    required this.kabinet,
    this.logoFile,
  });

  @override
  List<Object?> get props => [kabinet, logoFile];
}

class UpdateAboutEvent extends HimtikaManagementEvent {
  final HimtikaAbout about;

  const UpdateAboutEvent({required this.about});

  @override
  List<Object?> get props => [about];
}

class CreateDivisiEvent extends HimtikaManagementEvent {
  final HimtikaDivisi divisi;
  final File? logoFile;

  const CreateDivisiEvent({
    required this.divisi,
    this.logoFile,
  });

  @override
  List<Object?> get props => [divisi, logoFile];
}

class UpdateDivisiEvent extends HimtikaManagementEvent {
  final HimtikaDivisi divisi;
  final File? logoFile;

  const UpdateDivisiEvent({
    required this.divisi,
    this.logoFile,
  });

  @override
  List<Object?> get props => [divisi, logoFile];
}

class DeleteDivisiEvent extends HimtikaManagementEvent {
  final String divisiId;

  const DeleteDivisiEvent({required this.divisiId});

  @override
  List<Object?> get props => [divisiId];
}

class CreatePengurusEvent extends HimtikaManagementEvent {
  final HimtikaPengurus pengurus;
  final File? fotoFile;

  const CreatePengurusEvent({
    required this.pengurus,
    this.fotoFile,
  });

  @override
  List<Object?> get props => [pengurus, fotoFile];
}

class UpdatePengurusEvent extends HimtikaManagementEvent {
  final HimtikaPengurus pengurus;
  final File? fotoFile;

  const UpdatePengurusEvent({
    required this.pengurus,
    this.fotoFile,
  });

  @override
  List<Object?> get props => [pengurus, fotoFile];
}

class DeletePengurusEvent extends HimtikaManagementEvent {
  final String pengurusId;

  const DeletePengurusEvent({required this.pengurusId});

  @override
  List<Object?> get props => [pengurusId];
}

class SelectDivisiFilterEvent extends HimtikaManagementEvent {
  final String? divisiId;

  const SelectDivisiFilterEvent({this.divisiId});

  @override
  List<Object?> get props => [divisiId];
}
