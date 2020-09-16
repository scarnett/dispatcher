import 'package:dispatcher/views/auth/auth.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthStatusChanged extends AuthEvent {
  final AuthStatus status;

  const AuthStatusChanged(
    this.status,
  );

  @override
  List<Object> get props => [status];
}

class AuthLogoutRequested extends AuthEvent {}

class SetAuthFormMode extends AuthEvent {
  final AuthFormMode mode;

  const SetAuthFormMode(
    this.mode,
  );

  @override
  List<Object> get props => [mode];
}
