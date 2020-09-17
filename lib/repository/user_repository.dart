import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  User _user;

  Future<User> getUser() async {
    if (_user != null) {
      return _user;
    }

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    _user = _firebaseAuth.currentUser;
    return _user;
  }
}
