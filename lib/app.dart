import 'package:dispatcher/config.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/route/route_utils.dart';
import 'package:dispatcher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen/screen.dart';

class DispatcherApp extends StatelessWidget {
  final String token;
  final GlobalKey<NavigatorState> appNavKey = GlobalKey<NavigatorState>();

  DispatcherApp({
    Key key,
    this.token,
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
      MaterialApp(
        title: AppLocalizations.appTitle,
        theme: appThemeData,
        debugShowCheckedModeBanner: AppConfig.isDebug(context),
        localizationsDelegates: [
          AppLocalizationsDelegate(),
        ],
        navigatorKey: appNavKey,
        onGenerateRoute: (RouteSettings settings) => getAppRoute(
          settings,
        ),
      );
}
