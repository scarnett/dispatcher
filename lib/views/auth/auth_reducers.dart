import 'package:dispatcher/views/auth/auth_actions.dart';
import 'package:dispatcher/views/auth/auth_state.dart';
import 'package:redux/redux.dart';

final authReducer = combineReducers<AuthState>([
  TypedReducer<AuthState, AuthFormModeAction>(_setFormMode),
]);

AuthState _setFormMode(
  AuthState oldAuthState,
  AuthFormModeAction action,
) {
  return oldAuthState.copyWith(formMode: action.mode);
}
