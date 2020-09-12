import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:redux/redux.dart';

class AuthViewModel {
  final bool busy;
  final AuthFormMode formMode;

  AuthViewModel({
    this.busy,
    this.formMode,
  });

  static AuthViewModel fromStore(
    Store<AppState> store,
  ) =>
      AuthViewModel(
        busy: store.state.busy,
        formMode: store.state.authState.formMode,
      );
}
