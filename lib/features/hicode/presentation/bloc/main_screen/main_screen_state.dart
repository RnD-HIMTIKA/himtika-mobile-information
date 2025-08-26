part of 'main_screen_bloc.dart';

enum HicodeStatus { initial, loading, success, failure }

class HicodeState extends Equatable {
  final HicodeStatus status;
  final List<HiCodeCategory> categories;
  final List<HiCodeMaterial> materials;
  final bool isExamReady;
  final String? errorMessage;

  const HicodeState({
    this.status = HicodeStatus.initial,
    this.categories = const [],
    this.materials = const [],
    this.isExamReady = false,
    this.errorMessage,
  });

  HicodeState copyWith({
    HicodeStatus? status,
    List<HiCodeCategory>? categories,
    List<HiCodeMaterial>? materials,
    bool? isExamReady,
    String? errorMessage,
  }) {
    return HicodeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      materials: materials ?? this.materials,
      isExamReady: isExamReady ?? this.isExamReady,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, materials, isExamReady, errorMessage];
}