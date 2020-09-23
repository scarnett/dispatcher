import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class UserRepository {
  firebase.User _firebaseUser;

  Future<firebase.User> getFirebaseUser() async {
    if (_firebaseUser != null) {
      return _firebaseUser;
    }

    final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;
    _firebaseUser = _firebaseAuth.currentUser;
    return _firebaseUser;
  }
}
