part of 'login_bloc.dart';

@immutable
class LoginState extends Equatable {
  final FormzStatus status;
  final Email email;
  final Password password;

  const LoginState({
    this.status = FormzStatus.pure,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
  });

  LoginState copyWith({
    FormzStatus status,
    Email email,
    Password password,
  }) =>
      LoginState(
        status: status ?? this.status,
        email: email ?? this.email,
        password: password ?? this.password,
      );

  @override
  List<Object> get props => [status, email, password];

  @override
  String toString() => 'LoginState{status: $status, email: $email}';
}
