import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dispatcher/models/user.dart';
import 'package:dispatcher/repository/repository.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/auth_service.dart';
import 'package:dispatcher/views/auth/bloc/auth_event.dart';
import 'package:dispatcher/views/auth/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
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
    } else if (event is LoadUser) {
      yield await _mapLoadUserToState(event);
    } else if (event is UpdateFcmToken) {
      yield await _mapUpdateFcmTokenToState(event);
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
      final firebase.User firebaseUser = await _tryGetFirebaseUser();
      if ((firebaseUser != null) && !firebaseUser.isAnonymous) {
        final User user = await tryGetUser(firebaseUser);
        return AuthState.authenticated(firebaseUser, user);
      }
    }

    switch (event.status) {
      case AuthStatus.UNAUTHENTICATED:
        return const AuthState.unauthenticated();

      case AuthStatus.AUTHENTICATED:
        final firebase.User firebaseUser = await _tryGetFirebaseUser();
        final User user = await tryGetUser(firebaseUser);
        return AuthState.authenticated(firebaseUser, user);

      case AuthStatus.UNKNOWN:
      default:
        return const AuthState.unknown();
    }
  }

  Future<AuthState> _mapLoadUserToState(
    LoadUser event,
  ) async {
    User user = await tryGetUser(state.firebaseUser);
    return state.copyWith(
      user: user,
    );
  }

  Future<AuthState> _mapUpdateFcmTokenToState(
    UpdateFcmToken event,
  ) async {
    await updateFcmToken(state.firebaseUser.uid, event.token);

    return state.copyWith(
      user: state.user.copyWith(
        fcm: state.user.fcm.copyWith(token: event.token),
      ),
    );
  }

  Future<firebase.User> _tryGetFirebaseUser() async {
    try {
      return await _userRepository.getFirebaseUser();
    } on Exception {
      return null;
    }
  }
}
