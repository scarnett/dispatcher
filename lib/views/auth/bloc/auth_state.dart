import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

@immutable
class AuthState extends Equatable {
  final AuthStatus status;
  final AuthFormMode mode;
  final User user;
  final String token;

  const AuthState._({
    this.status = AuthStatus.UNKNOWN,
    this.mode = AuthFormMode.LOGIN,
    this.user,
    this.token,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(
    User user,
    String token,
  ) : this._(
          status: AuthStatus.AUTHENTICATED,
          user: user,
          token: token,
        );

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.UNAUTHENTICATED);

  const AuthState.logout()
      : this._(
          user: null,
          token: null,
          status: AuthStatus.UNAUTHENTICATED,
        );

  const AuthState.formMode(
    AuthFormMode mode,
  ) : this._(mode: mode);

  AuthState copyWith({
    AuthFormMode mode,
  }) =>
      AuthState._(
        mode: mode ?? this.mode,
      );

  @override
  List<Object> get props => [status, mode, user, token];

  @override
  String toString() =>
      'AuthState{status: $status, mode: $mode, user: $user, token: $token}';
}
