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

  const AuthState._({
    this.status = AuthStatus.UNKNOWN,
    this.mode = AuthFormMode.LOGIN,
    this.firebaseUser,
    this.user,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(
    firebase.User firebaseUser,
    User user,
  ) : this._(
          status: AuthStatus.AUTHENTICATED,
          firebaseUser: firebaseUser,
          user: user,
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
          status: AuthStatus.UNAUTHENTICATED,
        );

  AuthState copyWith({
    AuthStatus status,
    firebase.User firebaseUser,
    User user,
  }) =>
      AuthState._(
        status: status ?? this.status,
        firebaseUser: firebaseUser ?? this.firebaseUser,
        user: user ?? this.user,
      );

  @override
  List<Object> get props => [status, mode, firebaseUser, user];

  @override
  String toString() =>
      'AuthState{status: $status, firebaseUser: ${firebaseUser?.displayName}, user: $user}';
}
