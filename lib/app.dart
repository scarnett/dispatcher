import 'package:dispatcher/config.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/repository/repository.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/auth_view.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/home/home_view.dart';
import 'package:dispatcher/views/landing/landing_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:screen/screen.dart';

class DispatcherApp extends StatelessWidget {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  DispatcherApp({
    Key key,
    @required this.authRepository,
    @required this.userRepository,
  }) : super(key: key) {
    // Keeps the screen on
    Screen.keepOn(true);

    // Status bar configuration
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    // Set the orientation to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      RepositoryProvider.value(
        value: authRepository,
        child: BlocProvider(
          create: (BuildContext context) => AuthBloc(
            authRepository: authRepository,
            userRepository: userRepository,
          ),
          child: DispatcherAppView(),
        ),
      );
}

class DispatcherAppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<DispatcherAppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState;

  @override
  Widget build(
    BuildContext context,
  ) =>
      MaterialApp(
        title: AppLocalizations.appTitle,
        theme: appThemeData,
        debugShowCheckedModeBanner: AppConfig.isDebug(context),
        localizationsDelegates: [
          AppLocalizationsDelegate(),
        ],
        navigatorKey: _navigatorKey,
        builder: (
          BuildContext context,
          Widget child,
        ) =>
            BlocListener<AuthBloc, AuthState>(
          listener: (
            BuildContext context,
            AuthState state,
          ) {
            switch (state.status) {
              case AuthStatus.AUTHENTICATED:
                _navigator.pushAndRemoveUntil<void>(
                    HomeView.route(), (route) => false);

                break;

              case AuthStatus.UNAUTHENTICATED:
                _navigator.pushAndRemoveUntil<void>(
                    AuthView.route(), (route) => false);

                break;

              default:
                break;
            }
          },
          child: child,
        ),
        onGenerateRoute: (RouteSettings settings) => LandingView.route(),
      );
}
