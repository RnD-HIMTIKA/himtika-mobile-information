part of 'registration_bloc.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

class SignUpButtonPressed extends RegistrationEvent {
  final String email;
  final String password;

  const SignUpButtonPressed({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}