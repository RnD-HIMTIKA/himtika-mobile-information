import 'package:equatable/equatable.dart';

enum ProfileFormStatus { 
  initial, 
  loading, 
  loaded, 
  validating, // Status saat validasi step 1 berjalan
  submitting, 
  success, 
  failure 
}

class ProfileFormState extends Equatable {
  final ProfileFormStatus status;
  final int currentStep;
  final bool isFromUnsika;

  // Prefill data dari server
  final String? email;
  final String? username;

  // Auto filled dari roles (readonly)
  final String? angkatan;
  final String? fakultas;
  final String? prodi;

  final String? errorMessage;

  const ProfileFormState({
    this.status = ProfileFormStatus.initial,
    this.currentStep = 0,
    this.isFromUnsika = false,
    this.email,
    this.username,
    this.angkatan,
    this.fakultas,
    this.prodi,
    this.errorMessage,
  });

  int get totalSteps => isFromUnsika ? 2 : 1;

  ProfileFormState copyWith({
    ProfileFormStatus? status,
    int? currentStep,
    bool? isFromUnsika,
    String? email,
    String? username,
    String? angkatan,
    String? fakultas,
    String? prodi,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileFormState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      isFromUnsika: isFromUnsika ?? this.isFromUnsika,
      email: email ?? this.email,
      username: username ?? this.username,
      angkatan: angkatan ?? this.angkatan,
      fakultas: fakultas ?? this.fakultas,
      prodi: prodi ?? this.prodi,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentStep,
        isFromUnsika,
        email,
        username,
        angkatan,
        fakultas,
        prodi,
        errorMessage,
      ];
}
