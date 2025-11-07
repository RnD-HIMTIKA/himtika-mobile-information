part of 'main_screen_bloc.dart';

enum HicodeStatus { initial, loading, success, failure }

class HicodeState extends Equatable {
  final HicodeStatus status;
  final List<HiCodeCategory> categories;
  final List<HiCodeMaterial> materials;
  final bool allMaterialsComplete;
  final bool canTakeExamToday;
  final DateTime? nextExamAvailableAt;
  
  final String? errorMessage;

  const HicodeState({
    this.status = HicodeStatus.initial,
    this.categories = const [],
    this.materials = const [],
    this.allMaterialsComplete = false,
    this.canTakeExamToday = false,
    this.nextExamAvailableAt,
    
    this.errorMessage,
  });

  HicodeState copyWith({
    HicodeStatus? status,
    List<HiCodeCategory>? categories,
    List<HiCodeMaterial>? materials,
    bool? allMaterialsComplete,
    bool? canTakeExamToday,
    DateTime? nextExamAvailableAt,
    
    String? errorMessage,
  }) {
    return HicodeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      materials: materials ?? this.materials,
      allMaterialsComplete: allMaterialsComplete ?? this.allMaterialsComplete,
      canTakeExamToday: canTakeExamToday ?? this.canTakeExamToday,
      nextExamAvailableAt: nextExamAvailableAt ?? this.nextExamAvailableAt,

      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status, 
        categories, 
        materials, 
        allMaterialsComplete,
        canTakeExamToday,
        nextExamAvailableAt,
        errorMessage
      ];
}