import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithEmail extends LoginEvent {
  final String email;
  final String password;

  const LoginWithEmail(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LoginWithGoogle extends LoginEvent {
  const LoginWithGoogle();
}