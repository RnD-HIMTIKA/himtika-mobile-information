import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../domain/usecases/get_profile_form_data.dart';
import '../../../domain/usecases/submit_profile_form.dart';
import '../../../domain/usecases/validate_profile_step1.dart';
import 'form_event.dart';
import 'form_state.dart';

class ProfileFormBloc extends Bloc<ProfileFormEvent, ProfileFormState> {
  final GetProfileFormData _getProfileFormData;
  final SubmitProfileForm _submitProfileForm;
  final ValidateProfileStep1 _validateProfileStep1;

  ProfileFormBloc({
    required GetProfileFormData getProfileFormData,
    required SubmitProfileForm submitProfileForm,
    required ValidateProfileStep1 validateProfileStep1,
  })  : _getProfileFormData = getProfileFormData,
        _submitProfileForm = submitProfileForm,
        _validateProfileStep1 = validateProfileStep1,
        super(const ProfileFormState()) {
    on<ProfileFormStarted>(_onStarted);
    on<ProfileFormNextStep>(_onNextStep);
    on<ProfileFormPrevStep>(_onPrevStep);
    on<ProfileFormSubmitted>(_onSubmitted);
    on<ProfileFormValidateStep1>(_onValidateStep1);
  }

  Future<void> _onStarted(
      ProfileFormStarted event, Emitter<ProfileFormState> emit) async {
    emit(state.copyWith(status: ProfileFormStatus.loading));
    try {
      final result = await _getProfileFormData();
      emit(state.copyWith(
        status: ProfileFormStatus.loaded,
        isFromUnsika: result.isFromUnsika,
        email: result.email,
        angkatan: result.angkatan,
        fakultas: result.fakultas,
        prodi: result.prodi,
        currentStep: 0,
      ));
    } catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      
      // 2. Pesan Profesional
      String message = "Gagal memuat data profil.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
        status: ProfileFormStatus.failure,
        errorMessage: message,
      ));
    }
  }

  void _onNextStep(ProfileFormNextStep event, Emitter<ProfileFormState> emit) {
    if (state.currentStep < state.totalSteps - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPrevStep(ProfileFormPrevStep event, Emitter<ProfileFormState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }
  
  Future<void> _onValidateStep1(
    ProfileFormValidateStep1 event,
    Emitter<ProfileFormState> emit,
  ) async {
    // Simpan data inputan pengguna ke dalam state saat validasi dimulai
    emit(state.copyWith(
      status: ProfileFormStatus.validating,
      username: event.username,
      clearError: true,
    ));
    try {
      final params = ValidateProfileStep1Params(
        fullName: event.fullName,
        username: event.username,
        phone: event.phone,
        dob: event.dob,
      );
      await _validateProfileStep1(params);
      
      // Jika validasi sukses, kembali ke 'loaded' dan langsung pindah langkah
      emit(state.copyWith(status: ProfileFormStatus.loaded));
      add(const ProfileFormNextStep());

    } catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);

      // 2. Pesan Profesional (Pesan dari use case sudah bagus)
      String message = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
        status: ProfileFormStatus.loaded,
        errorMessage: message,
      ));
    }
  }

  Future<void> _onSubmitted(
      ProfileFormSubmitted event, Emitter<ProfileFormState> emit) async {
    final usernameToSubmit = event.username.isNotEmpty ? event.username : state.username;
    
    emit(state.copyWith(status: ProfileFormStatus.submitting, clearError: true));
    try {
      final params = SubmitProfileFormParams(
        fullName: event.fullName,
        username: usernameToSubmit ?? '',
        phone: event.phone,
        dob: event.dob,
        kelas: event.kelas,
        isFromUnsika: state.isFromUnsika,
      );
      
      if (params.username.isEmpty) {
        throw Exception("Username wajib diisi.");
      }
      
      await _submitProfileForm(params);
      emit(state.copyWith(status: ProfileFormStatus.success));
    } on PostgrestException catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);

      // 2. Pesan Profesional
      String message;
      if (e.code == '23505') {
        message = 'Username atau nomor telepon sudah digunakan.';
      } else {
        message = "Terjadi kesalahan database. Coba lagi nanti.";
      }
      emit(state.copyWith(
        status: ProfileFormStatus.failure,
        errorMessage: message,
      ));
    } catch (e, stackTrace) { // Tambah stackTrace
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);

      // 2. Pesan Profesional (Pesan dari use case sudah bagus)
      String message = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
        status: ProfileFormStatus.failure,
        errorMessage: message,
      ));
    }
  }
}