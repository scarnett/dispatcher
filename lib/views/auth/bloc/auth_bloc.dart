import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dispatcher/graphql/user.dart';
import 'package:dispatcher/models/user.dart';
import 'package:dispatcher/repository/repository.dart';
import 'package:dispatcher/graphql/service.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/bloc/auth_event.dart';
import 'package:dispatcher/views/auth/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  StreamSubscription<AuthStatus> _authStatusSubscription;
  GraphQLService _service;
  Logger _logger = Logger();

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
      yield _mapAuthFormModeToState(event);
    } else if (event is LoadUser) {
      yield await _mapLoadUserToState(event);
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
        final String token = await firebaseUser.getIdToken();
        final User user = await _tryGetUser(firebaseUser.uid, token);
        return AuthState.authenticated(firebaseUser, user, token);
      }
    }

    switch (event.status) {
      case AuthStatus.UNAUTHENTICATED:
        return const AuthState.unauthenticated();

      case AuthStatus.AUTHENTICATED:
        final firebase.User firebaseUser = await _tryGetFirebaseUser();
        final String token = await firebaseUser.getIdToken();
        final User user = await _tryGetUser(firebaseUser.uid, token);
        return AuthState.authenticated(firebaseUser, user, token);

      case AuthStatus.UNKNOWN:
      default:
        return const AuthState.unknown();
    }
  }

  AuthState _mapAuthFormModeToState(
    SetAuthFormMode event,
  ) =>
      state.copyWith(
        mode: event.mode,
      );

  Future<AuthState> _mapLoadUserToState(
    LoadUser event,
  ) async {
    User user = await _tryGetUser(state.firebaseUser.uid, state.token);
    return state.copyWith(
      user: user,
    );
  }

  Future<firebase.User> _tryGetFirebaseUser() async {
    try {
      return await _userRepository.getFirebaseUser();
    } on Exception {
      return null;
    }
  }

  Future<User> _tryGetUser(
    String identifier,
    String token,
  ) async {
    try {
      _service = GraphQLService(token);

      final QueryResult result = await _service.performMutation(
        fetchUserQueryStr,
        variables: {
          'identifier': identifier,
        },
      );

      if (result.hasException) {
        _logger.e(result.exception.graphqlErrors.toString());
        _logger.e(result.exception.clientException.toString());
      } else {
        dynamic users = result.data['users'];
        if ((users != null) && (users.length > 0)) {
          return User.fromJson(users[0]);
        }

        return null;
      }
    } catch (e) {
      _logger.e(e.toString());
    }

    return null;
  }
}
