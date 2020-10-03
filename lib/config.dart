import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

enum Flavor {
  DEV,
  RELEASE,
}

enum HiveBoxes {
  APP_BOX,
}

class AppConfig extends InheritedWidget {
  final Flavor flavor;

  AppConfig({
    @required this.flavor,
    @required Widget child,
  }) : super(child: child);

  static AppConfig of(
    BuildContext context,
  ) =>
      context.dependOnInheritedWidgetOfExactType(aspect: AppConfig);

  static bool isDebug(
    BuildContext context,
  ) {
    Flavor flavor = AppConfig.of(context).flavor;
    switch (flavor) {
      case Flavor.DEV:
        return true;

      case Flavor.RELEASE:
      default:
        return false;
    }
  }

  static bool isRelease(
    BuildContext context,
  ) {
    Flavor flavor = AppConfig.of(context).flavor;
    switch (flavor) {
      case Flavor.RELEASE:
        return true;

      case Flavor.DEV:
      default:
        return false;
    }
  }

  @override
  bool updateShouldNotify(
    InheritedWidget oldWidget,
  ) =>
      false;
}
