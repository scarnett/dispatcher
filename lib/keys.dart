import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppKeys {
  static final GlobalKey<NavigatorState> appNavKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldState> appScaffoldKey =
      GlobalKey<ScaffoldState>();

  static final GlobalKey appBottomNavKey =
      GlobalKey(debugLabel: 'BottomNavigationBar');
}
