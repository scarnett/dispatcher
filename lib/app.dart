import 'package:dispatcher/config.dart';
import 'package:dispatcher/graphql/graphql_config.dart';
import 'package:dispatcher/graphql/graphql_redux.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/route/route_utils.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:screen/screen.dart';

class DispatcherApp extends StatelessWidget {
  final Store<AppState> store;
  final GlobalKey<NavigatorState> appNavKey = GlobalKey<NavigatorState>();

  DispatcherApp({
    Key key,
    this.store,
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
      GraphXProvider<AppState>(
        store: store,
        client: HasuraConfig.initailizeClient(null), // TODO!
        child: MaterialApp(
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
        ),
      );
}
