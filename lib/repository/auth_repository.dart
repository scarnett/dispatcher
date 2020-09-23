import 'dart:async';
import 'package:dispatcher/services/shared_preference_service.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:meta/meta.dart';

class AuthRepository {
  final StreamController<AuthStatus> _controller =
      StreamController<AuthStatus>();

  Stream<AuthStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthStatus.UNAUTHENTICATED;
    yield* _controller.stream;
  }

  Future<void> logIn({
    @required String email,
    @required String password,
  }) async {
    assert(email != null);
    assert(password != null);

    final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store the auth token
    await sharedPreferenceService.getSharedPreferencesInstance();
    await sharedPreferenceService
        .setToken(await _firebaseAuth.currentUser.getIdToken(true));

    _controller.add(AuthStatus.AUTHENTICATED);
  }

  void logOut() async {
    firebase.FirebaseAuth.instance.signOut();

    // Remove the auth token
    await sharedPreferenceService.getSharedPreferencesInstance();
    await sharedPreferenceService.clearToken();

    _controller.add(AuthStatus.LOGOUT);
  }

  void dispose() => _controller.close();
}
