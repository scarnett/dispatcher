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

class LoadUser extends AuthEvent {
  const LoadUser();

  @override
  List<Object> get props => [];
}
