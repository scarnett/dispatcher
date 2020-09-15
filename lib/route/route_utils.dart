import 'package:dispatcher/route/route_transitions.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/views/avatar/avatar_camera_view.dart';
import 'package:dispatcher/views/connect/connect_view.dart';
import 'package:dispatcher/views/contacts/contact/contact_view.dart';
import 'package:dispatcher/views/contacts/contacts_view.dart';
import 'package:dispatcher/views/landing/landing_view.dart';
import 'package:dispatcher/views/migrate/from_device/from_device_view.dart';
import 'package:dispatcher/views/migrate/to_device/to_device_view.dart';
import 'package:dispatcher/views/pin/pin_view.dart';
import 'package:flutter/material.dart';

/// Handles the app route transitions
MaterialPageRoute getAppRoute(
  RouteSettings settings,
) {
  // Contact
  if (settings.name == AppRoutes.contact.name) {
    return SlideLeftRoute(ContactView(), settings: settings);
    // Contacts
  } else if (settings.name == AppRoutes.contacts.name) {
    return SlideUpRoute(ContactsView(), settings: settings);
    // Connect
  } else if (settings.name == AppRoutes.connect.name) {
    return SlideUpRoute(ConnectView(), settings: settings);
    // Avatar Camera
  } else if (settings.name == AppRoutes.avatarCamera.name) {
    return SlideUpRoute(AvatarCameraView(), settings: settings);
    // PIN
  } else if (settings.name == AppRoutes.changePIN.name) {
    return SlideLeftRoute(PINView(), settings: settings);
    // Migrate From Device
  } else if (settings.name == AppRoutes.migrateFrom.name) {
    return SlideLeftRoute(MigrateFromDeviceView(), settings: settings);
    // Migrate To Device
  } else if (settings.name == AppRoutes.migrateTo.name) {
    return SlideLeftRoute(MigrateToDeviceView(), settings: settings);
  }

  // Default route
  return MainRoute(
    LandingView(),
    settings: settings,
  );
}
