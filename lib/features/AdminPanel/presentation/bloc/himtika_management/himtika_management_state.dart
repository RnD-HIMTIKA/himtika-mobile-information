import 'package:equatable/equatable.dart';
import '../../../../himtika/domain/entities/himtika_kabinet.dart';
import '../../../../himtika/domain/entities/himtika_about.dart';
import '../../../../himtika/domain/entities/himtika_divisi.dart';
import '../../../../himtika/domain/entities/himtika_pengurus.dart';

enum HimtikaManagementStatus { initial, loading, success, failure }

class HimtikaManagementState extends Equatable {
  final HimtikaManagementStatus status;
  final HimtikaKabinet? kabinet;
  final HimtikaAbout? about;
  final List<HimtikaDivisi> divisiList;
  final List<HimtikaPengurus> pengurusList;
  final String? selectedDivisiId;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const HimtikaManagementState({
    this.status = HimtikaManagementStatus.initial,
    this.kabinet,
    this.about,
    this.divisiList = const [],
    this.pengurusList = const [],
    this.selectedDivisiId,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  List<HimtikaPengurus> get filteredPengurusList {
    if (selectedDivisiId == null || selectedDivisiId!.isEmpty) {
      return pengurusList;
    }
    return pengurusList.where((p) => p.divisiId == selectedDivisiId).toList();
  }

  HimtikaManagementState copyWith({
    HimtikaManagementStatus? status,
    HimtikaKabinet? kabinet,
    HimtikaAbout? about,
    List<HimtikaDivisi>? divisiList,
    List<HimtikaPengurus>? pengurusList,
    String? selectedDivisiId,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
  }) {
    return HimtikaManagementState(
      status: status ?? this.status,
      kabinet: kabinet ?? this.kabinet,
      about: about ?? this.about,
      divisiList: divisiList ?? this.divisiList,
      pengurusList: pengurusList ?? this.pengurusList,
      selectedDivisiId: selectedDivisiId ?? this.selectedDivisiId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        kabinet,
        about,
        divisiList,
        pengurusList,
        selectedDivisiId,
        isSubmitting,
        errorMessage,
        successMessage,
      ];
}
