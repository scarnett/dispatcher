import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class AuthState {
  final AuthFormMode formMode;

  AuthState({
    this.formMode,
  });

  AuthState copyWith({
    AuthFormMode formMode,
    bool forceNull = false,
  }) =>
      AuthState(
        formMode: formMode ?? this.formMode,
      );

  factory AuthState.initial() {
    return AuthState(
      formMode: AuthFormMode.LOGIN,
    );
  }
}
