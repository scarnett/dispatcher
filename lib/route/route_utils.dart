import 'package:dispatcher/route/route_transitions.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/views/connect/connect_view.dart';
import 'package:dispatcher/views/landing/landing_view.dart';
import 'package:flutter/material.dart';

/// Handles the app route transitions
MaterialPageRoute getAppRoute(
  RouteSettings settings,
) {
  // Connect
  if (settings.name == AppRoutes.connect.name) {
    return SlideUpRoute(ConnectView(), settings: settings);
  }

  // Default route
  return MainRoute(
    LandingView(),
    settings: settings,
  );
}
