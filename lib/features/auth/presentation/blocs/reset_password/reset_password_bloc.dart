import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../../../domain/usecases/update_user_password.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final UpdateUserPassword _updateUserPassword;

  ResetPasswordBloc({required UpdateUserPassword updateUserPassword})
      : _updateUserPassword = updateUserPassword,
        super(ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(ResetPasswordLoading());
    try {
      await _updateUserPassword(
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      emit(ResetPasswordSuccess());
    } on AuthException catch (e) {
      // PERBAIKAN DI SINI: Tangkap AuthException secara spesifik
      if (e.message.toLowerCase().contains('same password')) {
        emit(const ResetPasswordFailure('Password baru tidak boleh sama dengan password lama.'));
      } else {
        emit(ResetPasswordFailure(e.message));
      }
    } catch (e) {
      emit(ResetPasswordFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}