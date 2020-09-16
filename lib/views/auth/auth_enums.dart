import 'package:dispatcher/views/auth/create/create_form.dart';
import 'package:dispatcher/views/auth/login/login_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AuthStatus {
  UNKNOWN,
  AUTHENTICATED,
  UNAUTHENTICATED,
  LOGOUT,
}

enum AuthFormMode {
  CREATE,
  LOGIN,
}

extension AuthFormModeExtension on AuthFormMode {
  int get pageIndex {
    switch (this) {
      case AuthFormMode.LOGIN:
        return 0;

      case AuthFormMode.CREATE:
        return 1;

      default:
        return -1;
    }
  }

  Widget getForm() {
    switch (this) {
      case AuthFormMode.CREATE:
        return AuthCreateForm();

      case AuthFormMode.LOGIN:
        return AuthLoginForm();

      default:
        return Container();
    }
  }
}
