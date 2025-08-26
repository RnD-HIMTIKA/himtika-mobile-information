part of 'hicode_management_bloc.dart';

enum HicodeManagementStatus { initial, loading, success, failure }

class HicodeManagementState extends Equatable {
  final HicodeManagementStatus status;
  final List<Map<String, dynamic>> materials; // Kita gunakan Map sederhana untuk UI admin
  final String? errorMessage;

  const HicodeManagementState({
    this.status = HicodeManagementStatus.initial,
    this.materials = const [],
    this.errorMessage,
  });

  HicodeManagementState copyWith({
    HicodeManagementStatus? status,
    List<Map<String, dynamic>>? materials,
    String? errorMessage,
  }) {
    return HicodeManagementState(
      status: status ?? this.status,
      materials: materials ?? this.materials,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, materials, errorMessage];
}