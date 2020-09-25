import 'package:dispatcher/models/user.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:meta/meta.dart';

@immutable
class AuthState extends Equatable {
  final AuthStatus status;
  final AuthFormMode mode;
  final firebase.User firebaseUser;
  final User user;
  final String token;

  const AuthState._({
    this.status = AuthStatus.UNKNOWN,
    this.mode = AuthFormMode.LOGIN,
    this.firebaseUser,
    this.user,
    this.token,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(
    firebase.User firebaseUser,
    User user,
    String token,
  ) : this._(
          status: AuthStatus.AUTHENTICATED,
          firebaseUser: firebaseUser,
          user: user,
          token: token,
        );

  const AuthState.unauthenticated()
      : this._(
          status: AuthStatus.UNAUTHENTICATED,
        );

  const AuthState.loadUserFail() : this._();

  const AuthState.logout()
      : this._(
          firebaseUser: null,
          user: null,
          token: null,
          status: AuthStatus.UNAUTHENTICATED,
        );

  const AuthState.formMode(
    AuthFormMode mode,
  ) : this._(
          mode: mode,
        );

  AuthState copyWith({
    AuthStatus status,
    AuthFormMode mode,
    firebase.User firebaseUser,
    User user,
    String token,
  }) =>
      AuthState._(
        status: status ?? this.status,
        mode: mode ?? this.mode,
        firebaseUser: firebaseUser ?? this.firebaseUser,
        user: user ?? this.user,
        token: token ?? this.token,
      );

  @override
  List<Object> get props => [status, mode, firebaseUser, user, token];

  @override
  String toString() =>
      'AuthState{status: $status, mode: $mode, firebaseUser: ${firebaseUser?.displayName}, user: $user, token: ${token?.substring(0, 50)}...}';
}
