import 'package:dispatcher/views/auth/auth_enums.dart';

class AuthFormModeAction {
  final AuthFormMode mode;

  AuthFormModeAction(this.mode);

  @override
  String toString() => 'AuthFormModeAction{mode: $mode}';
}
