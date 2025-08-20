part of 'reset_password_bloc.dart';

abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();
  @override
  List<Object> get props => [];
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String password;
  final String confirmPassword;

  const ResetPasswordSubmitted({required this.password, required this.confirmPassword});

  @override
  List<Object> get props => [password, confirmPassword];
}