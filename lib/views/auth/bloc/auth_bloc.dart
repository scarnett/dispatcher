import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dispatcher/repository/repository.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/bloc/auth_event.dart';
import 'package:dispatcher/views/auth/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  StreamSubscription<AuthStatus> _authStatusSubscription;

  AuthBloc({
    @required AuthRepository authRepository,
    @required UserRepository userRepository,
    String token,
  })  : assert(authRepository != null),
        assert(userRepository != null),
        _authRepository = authRepository,
        _userRepository = userRepository,
        super(const AuthState.unknown()) {
    _authStatusSubscription = _authRepository.status.listen(
      (status) => add(AuthStatusChanged(status)),
    );
  }

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AuthStatusChanged) {
      yield await _mapAuthStatusChangedToState(event);
    } else if (event is AuthLogoutRequested) {
      _authRepository.logOut();
    } else if (event is SetAuthFormMode) {
      yield _mapAuthFormModeToStates(event);
    }
  }

  @override
  Future<void> close() {
    _authStatusSubscription?.cancel();
    _authRepository.dispose();
    return super.close();
  }

  Future<AuthState> _mapAuthStatusChangedToState(
    AuthStatusChanged event,
  ) async {
    if (event.status == AuthStatus.LOGOUT) {
      return AuthState.logout();
    } else {
      final User user = await _tryGetUser();
      if ((user != null) && !user.isAnonymous) {
        return AuthState.authenticated(user, await user.getIdToken());
      }
    }

    switch (event.status) {
      case AuthStatus.UNAUTHENTICATED:
        return const AuthState.unauthenticated();

      case AuthStatus.AUTHENTICATED:
        final User user = await _tryGetUser();
        return AuthState.authenticated(user, await user.getIdToken());

      case AuthStatus.UNKNOWN:
      default:
        return const AuthState.unknown();
    }
  }

  AuthState _mapAuthFormModeToStates(
    SetAuthFormMode event,
  ) =>
      state.copyWith(
        mode: event.mode,
      );

  Future<User> _tryGetUser() async {
    try {
      return await _userRepository.getUser();
    } on Exception {
      return null;
    }
  }
}
