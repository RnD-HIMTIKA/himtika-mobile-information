import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithEmail extends LoginEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginWithEmail(this.email, this.password, this.rememberMe);

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class LoginWithGoogle extends LoginEvent {
  const LoginWithGoogle();
}

// Event untuk load data "Remember Me" saat halaman login dibuka
class LoadRememberMeData extends LoginEvent {
  const LoadRememberMeData();
}