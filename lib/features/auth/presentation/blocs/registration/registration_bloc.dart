import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/usecases/sign_up_with_email.dart';

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final SignUpWithEmail _signUpWithEmail;

  RegistrationBloc({required SignUpWithEmail signUpWithEmail})
      : _signUpWithEmail = signUpWithEmail,
        super(RegistrationInitial()) {
    on<SignUpButtonPressed>(_onSignUpButtonPressed);
  }

  Future<void> _onSignUpButtonPressed(
    SignUpButtonPressed event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());
    try {
      await _signUpWithEmail(event.email, event.password);

      // SIMPAN STATUS SETELAH SIGN UP BERHASIL
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('verification_email', event.email);
      
      emit(RegistrationSuccess(email: event.email));
    } catch (e) {
      // Tangkap semua jenis error dan tampilkan pesannya dengan bersih
      // .replaceFirst() berguna untuk menghapus prefix "Exception: "
      emit(RegistrationFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}