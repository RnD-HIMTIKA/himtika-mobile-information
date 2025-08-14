import 'package:equatable/equatable.dart';

abstract class ProfileFormEvent extends Equatable {
  const ProfileFormEvent();

  @override
  List<Object?> get props => [];
}

/// di panggil saat halaman form dibuka
class ProfileFormStarted extends ProfileFormEvent {
  const ProfileFormStarted();
}

/// tombol "Next" di stepper
class ProfileFormNextStep extends ProfileFormEvent {
  const ProfileFormNextStep();
}

/// tombol "Previous" di stepper
class ProfileFormPrevStep extends ProfileFormEvent {
  const ProfileFormPrevStep();
}

/// submit step terakhir -> update ke supabase
/// submit step terakhir -> update ke Supabase
class ProfileFormSubmitted extends ProfileFormEvent {
  final String fullName;
  final String username;
  final String email;     // read-only di UI, tetap disertakan
  final String phone;
  final String dob;       // dd/mm/yyyy (sesuai UI)
  final String? kelas;    // nullable, kalau bukan unsika bisa null

  const ProfileFormSubmitted({
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.dob,
    required this.kelas,
  });

  @override
  List<Object?> get props => [fullName, username, email, phone, dob, kelas];
}