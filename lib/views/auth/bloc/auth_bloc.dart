import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dispatcher/models/user.dart';
import 'package:dispatcher/repository/repository.dart';
import 'package:dispatcher/utils/push_utils.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/auth_service.dart';
import 'package:dispatcher/views/auth/bloc/auth_event.dart';
import 'package:dispatcher/views/auth/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_messaging/firebase_messaging.dart';
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
      yield await _mapAuthLogoutRequestedState(event);
    } else if (event is LoadUser) {
      yield await _mapLoadUserToState(event);
    } else if (event is ConfigureNotifications) {
      yield await _mapConfigureNotificationsToState(event);
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
        return AuthState.authenticated(firebaseUser);
      }
    }

    switch (event.status) {
      case AuthStatus.UNAUTHENTICATED:
        return const AuthState.unauthenticated();

      case AuthStatus.AUTHENTICATED:
        final firebase.User firebaseUser = await _tryGetFirebaseUser();
        if (firebaseUser == null) {
          return const AuthState.unauthenticated();
        }

        return AuthState.authenticated(firebaseUser);

      case AuthStatus.LOGOUT:
        return AuthState.logout();

      case AuthStatus.UNKNOWN:
      default:
        return const AuthState.unknown();
    }
  }

  Future<AuthState> _mapAuthLogoutRequestedState(
    AuthLogoutRequested event,
  ) async {
    _authRepository.logout();
    return AuthState.logout();
  }

  Future<AuthState> _mapLoadUserToState(
    LoadUser event,
  ) async {
    User user = await tryGetUser(event.client, state.firebaseUser);
    return state.copyWith(
      user: user,
    );
  }

  Future<AuthState> _mapConfigureNotificationsToState(
    ConfigureNotifications event,
  ) async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    // Listen for fcm token refresh
    Stream<String> fcmStream = _firebaseMessaging.onTokenRefresh;
    fcmStream.distinct().listen((String token) async* {
      await updateFcmToken(state.firebaseUser.uid, token);

      yield state.copyWith(
        user: state.user.copyWith(
          fcm: state.user.fcm.copyWith(token: token),
        ),
      );
    });

    // Listen for push messages coming from firebase
    configLocalNotification();
    listenForPushMessages(_firebaseMessaging);
    return state;
  }

  Future<firebase.User> _tryGetFirebaseUser() async {
    try {
      return await _userRepository.getFirebaseUser();
    } on Exception {
      return null;
    }
  }
}
