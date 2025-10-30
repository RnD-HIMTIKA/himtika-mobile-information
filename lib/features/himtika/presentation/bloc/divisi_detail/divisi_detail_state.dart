part of 'divisi_detail_bloc.dart';

enum DivisiDetailStatus { initial, loading, success, failure }

class DivisiDetailState extends Equatable {
  const DivisiDetailState({
    this.status = DivisiDetailStatus.initial,
    this.title,
    this.gradientTitle,
    this.description,
    this.heroLogoPath,
    this.divisionHead, 
    this.departments = const [], 
  });

  final DivisiDetailStatus status;
  final String? title;
  final String? gradientTitle;
  final String? description;
  final String? heroLogoPath;
  final Map<String, String>? divisionHead; // Menyimpan data ketua
  final List<Map<String, dynamic>> departments; // Menyimpan data departemen

  DivisiDetailState copyWith({
    DivisiDetailStatus? status,
    String? title,
    String? gradientTitle,
    String? description,
    String? heroLogoPath,
    Map<String, String>? divisionHead,
    List<Map<String, dynamic>>? departments,
  }) {
    return DivisiDetailState(
      status: status ?? this.status,
      title: title ?? this.title,
      gradientTitle: gradientTitle ?? this.gradientTitle,
      description: description ?? this.description,
      heroLogoPath: heroLogoPath ?? this.heroLogoPath,
      divisionHead: divisionHead ?? this.divisionHead,
      departments: departments ?? this.departments,
    );
  }

  @override
  List<Object?> get props =>
      [status, title, gradientTitle, description, heroLogoPath, divisionHead, departments];
}
