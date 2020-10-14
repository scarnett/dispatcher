import 'dart:async';
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

  Future<void> login({
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

    _controller.add(AuthStatus.AUTHENTICATED);
  }

  void logout() async {
    await firebase.FirebaseAuth.instance.signOut();
    _controller.add(AuthStatus.LOGOUT);
  }

  void dispose() => _controller.close();
}
