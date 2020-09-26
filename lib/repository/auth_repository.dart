import 'dart:async';
import 'package:dispatcher/hive.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:hive/hive.dart';
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
    Box<Dispatcher> appBox = Hive.box<Dispatcher>(HiveBoxes.APP_BOX);
    appBox.add(
      appBox.get(0).copyWith(
            token: await _firebaseAuth.currentUser.getIdToken(true),
          ),
    );

    _controller.add(AuthStatus.AUTHENTICATED);
  }

  void logOut() async {
    firebase.FirebaseAuth.instance.signOut();

    // Remove the auth token
    Box<Dispatcher> appBox = Hive.box<Dispatcher>(HiveBoxes.APP_BOX);
    appBox.delete('token');

    _controller.add(AuthStatus.LOGOUT);
  }

  void dispose() => _controller.close();
}
