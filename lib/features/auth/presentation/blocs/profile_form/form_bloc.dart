import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/usecases/get_profile_form_data.dart'; // import use case
import '../../../domain/usecases/submit_profile_form.dart'; // import use case
import 'form_event.dart';
import 'form_state.dart';

class ProfileFormBloc extends Bloc<ProfileFormEvent, ProfileFormState> {
  // Hanya butuh use case, bukan client Supabase langsung
  final GetProfileFormData _getProfileFormData;
  final SubmitProfileForm _submitProfileForm;

  ProfileFormBloc({
    required GetProfileFormData getProfileFormData,
    required SubmitProfileForm submitProfileForm,
  })  : _getProfileFormData = getProfileFormData,
        _submitProfileForm = submitProfileForm,
        super(const ProfileFormState()) {
    on<ProfileFormStarted>(_onStarted);
    on<ProfileFormNextStep>(_onNextStep);
    on<ProfileFormPrevStep>(_onPrevStep);
    on<ProfileFormSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(
      ProfileFormStarted event, Emitter<ProfileFormState> emit) async {
    emit(state.copyWith(status: ProfileFormStatus.loading));
    try {
      // Panggil use case untuk mendapatkan data
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
        errorMessage: 'Error fetching data: $e',
      ));
    }
  }

  void _onNextStep(ProfileFormNextStep event, Emitter<ProfileFormState> emit) {
    final lastIndex = state.totalSteps - 1;
    if (state.currentStep < lastIndex) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPrevStep(ProfileFormPrevStep event, Emitter<ProfileFormState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> _onSubmitted(
      ProfileFormSubmitted event, Emitter<ProfileFormState> emit) async {
    emit(state.copyWith(status: ProfileFormStatus.submitting));
    try {
      // Buat parameter untuk use case
      final params = SubmitProfileFormParams(
        fullName: event.fullName,
        username: event.username,
        phone: event.phone,
        dob: event.dob,
        kelas: event.kelas,
        isFromUnsika: state.isFromUnsika,
      );

      // Panggil use case untuk submit data
      await _submitProfileForm(params);

      emit(state.copyWith(status: ProfileFormStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileFormStatus.failure,
        errorMessage: e.toString(), // Pesan error langsung dari use case
      ));
    }
  }
}