import 'package:dispatcher/views/auth/forms/auth_create_form.dart';
import 'package:dispatcher/views/auth/forms/auth_login_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  Widget getForm(
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    switch (this) {
      case AuthFormMode.CREATE:
        return AuthCreateForm(scaffoldKey: scaffoldKey);

      case AuthFormMode.LOGIN:
        return AuthLoginForm(scaffoldKey: scaffoldKey);

      default:
        return Container();
    }
  }
}
