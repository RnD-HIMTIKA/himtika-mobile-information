import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    } catch (e) {
      emit(state.copyWith(
        status: ProfileFormStatus.failure,
        errorMessage: e.toString(),
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

    } catch (e) {
      // Jika validasi gagal, kembali ke 'loaded' dan kirim pesan error
      emit(state.copyWith(
        status: ProfileFormStatus.loaded,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
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
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        emit(state.copyWith(
          status: ProfileFormStatus.failure,
          errorMessage: 'Username atau nomor telepon sudah digunakan.',
        ));
      } else {
        emit(state.copyWith(
          status: ProfileFormStatus.failure,
          errorMessage: 'Kesalahan Database: ${e.message}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileFormStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}