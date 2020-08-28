import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

enum Flavor {
  DEVELOPMENT,
  RELEASE,
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
      case Flavor.DEVELOPMENT:
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

      case Flavor.DEVELOPMENT:
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
