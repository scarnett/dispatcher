import 'package:dispatcher/views/auth/auth_view.dart';
import 'package:dispatcher/views/home/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandingView extends StatefulWidget {
  @override
  _LandingViewState createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(
    BuildContext context,
  ) =>
      StreamBuilder(
        stream: _firebaseAuth.authStateChanges(),
        builder: (
          BuildContext context,
          AsyncSnapshot<User> snapshot,
        ) {
          if (snapshot.hasData) {
            return HomeView();
          }

          return AuthView();
        },
      );
}
