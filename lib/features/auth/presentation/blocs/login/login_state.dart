import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  final String? email;
  final String? password;
  final bool rememberMe;

  const LoginInitial({this.email, this.password, this.rememberMe = false});

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}