import 'package:dispatcher/views/auth/bloc/auth.dart';
import 'package:dispatcher/views/home/bloc/home.dart';
import 'package:dispatcher/views/home/bloc/home_bloc.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/user/user_graphql.dart';
import 'package:dispatcher/views/auth/auth_view.dart';
import 'package:dispatcher/views/home/bloc/home_events.dart';
import 'package:dispatcher/views/home/home_view.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LandingView extends StatefulWidget {
  @override
  _LandingViewState createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User user;
  String token;

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
  }

  Future<User> checkCurrentUser() async {
    try {
      user = _firebaseAuth.currentUser;
      if (user != null) {
        token = await user.getIdToken();
      }

      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      FutureBuilder<User>(
        future: checkCurrentUser(),
        builder: (
          BuildContext context,
          AsyncSnapshot<User> snapshot,
        ) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Scaffold(
                key: _scaffoldKey,
                body: Container(
                  child: Spinner(
                    message: AppLocalizations.of(context).loading,
                  ),
                ),
              );

            case ConnectionState.done:
              if (snapshot.data != null) {
                return BlocProvider<HomeBloc>(
                  create: (
                    BuildContext context,
                  ) =>
                      HomeBloc(token)
                        ..add(
                          FetchHomeData(
                            fetchUserQueryStr,
                            variables: {'identifier': user.uid},
                          ),
                        ),
                  child: HomeView(),
                );
              }

              return BlocProvider<AuthBloc>(
                create: (
                  BuildContext context,
                ) =>
                    AuthBloc(),
                child: AuthView(),
              );
          }

          return null;
        },
      );

  @override
  void dispose() {
    _scaffoldKey.currentState.dispose();
    super.dispose();
  }
}
