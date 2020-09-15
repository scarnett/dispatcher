import 'package:dispatcher/views/auth/bloc/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.initial());

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is SetFormMode) {
      yield _mapFormModeToStates(event);
    } else if (event is SetAuthorizing) {
      yield _mapAuthorizingToStates(event);
    } else if (event is SetCreating) {
      yield _mapCreatingToStates(event);
    }
  }

  AuthState _mapFormModeToStates(
    SetFormMode event,
  ) =>
      state.copyWith(
        mode: event.mode,
      );

  AuthState _mapAuthorizingToStates(
    SetAuthorizing event,
  ) =>
      state.copyWith(
        authorizing: event.authorizing,
      );

  AuthState _mapCreatingToStates(
    SetCreating event,
  ) =>
      state.copyWith(
        creating: event.creating,
      );
}
