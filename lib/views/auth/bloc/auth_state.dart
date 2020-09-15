import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class AuthState extends Equatable {
  final AuthFormMode mode;
  final bool authorizing;
  final bool creating;

  const AuthState._({
    this.mode = AuthFormMode.LOGIN,
    this.authorizing = false,
    this.creating = false,
  });

  const AuthState.initial() : this._();

  const AuthState.formMode(
    AuthFormMode mode,
  ) : this._(mode: mode);

  const AuthState.authorizing(
    bool authorizing,
  ) : this._(authorizing: authorizing);

  const AuthState.creating(
    bool creating,
  ) : this._(creating: creating);

  AuthState copyWith({
    AuthFormMode mode,
    bool authorizing,
    bool creating,
  }) =>
      AuthState._(
        mode: mode ?? this.mode,
        authorizing: authorizing ?? this.authorizing,
        creating: creating ?? this.creating,
      );

  @override
  List<Object> get props => [mode, authorizing, creating];

  @override
  String toString() =>
      'AuthState{mode: $mode, authorizing: $authorizing, creating: $creating}';
}
