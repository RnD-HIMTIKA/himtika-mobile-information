part of 'registration_bloc.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();
  @override
  List<Object> get props => [];
}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {
  final String email;
  const RegistrationSuccess({required this.email});
    @override
  List<Object> get props => [email];
}

class RegistrationFailure extends RegistrationState {
  final String error;
  const RegistrationFailure(this.error);
    @override
  List<Object> get props => [error];
}