import 'package:dispatcher/route/route_transitions.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/views/avatar/avatar_camera_view.dart';
import 'package:dispatcher/views/connect/connect_view.dart';
import 'package:dispatcher/views/contacts/contact/contact_view.dart';
import 'package:dispatcher/views/home/home_view.dart';
import 'package:dispatcher/views/landing/landing_view.dart';
import 'package:dispatcher/views/migrate/from_device/from_device_view.dart';
import 'package:dispatcher/views/migrate/to_device/to_device_view.dart';
import 'package:dispatcher/views/pin/pin_view.dart';
import 'package:flutter/material.dart';

/// Handles the app route transitions
MaterialPageRoute getAppRoute(
  RouteSettings settings,
) {
  if (settings.name == AppRoutes.contact.path) {
    return SlideLeftRoute(ContactView(), settings: settings);
  } else if (settings.name == AppRoutes.home.path) {
    return MainRoute(HomeView(), settings: settings);
  } else if (settings.name == AppRoutes.connect.path) {
    return SlideUpRoute(ConnectView(), settings: settings);
  } else if (settings.name == AppRoutes.avatarCamera.path) {
    return SlideUpRoute(AvatarCameraView(), settings: settings);
  } else if (settings.name == AppRoutes.changePIN.path) {
    return SlideLeftRoute(PINView(), settings: settings);
  } else if (settings.name == AppRoutes.migrateFrom.path) {
    return SlideLeftRoute(MigrateFromDeviceView(), settings: settings);
  } else if (settings.name == AppRoutes.migrateTo.path) {
    return SlideLeftRoute(MigrateToDeviceView(), settings: settings);
  }

  // Default route
  return MainRoute(LandingView(), settings: settings);
}
