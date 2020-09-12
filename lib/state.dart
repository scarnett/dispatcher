import 'package:dispatcher/device/device_state.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/route/route_model.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/views/auth/auth_state.dart';
import 'package:dispatcher/views/connect/connect_state.dart';
import 'package:dispatcher/views/contacts/contacts_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class AppState {
  final bool busy;
  final AuthState authState;
  final DeviceState deviceState;
  final ContactsState contactsState;
  final ConnectState connectState;
  final List<AppRoute> route;
  final Message message;
  final int selectedTabIndex;

  AppState({
    this.busy,
    this.authState,
    this.deviceState,
    this.contactsState,
    this.connectState,
    this.route,
    this.message,
    this.selectedTabIndex,
  });

  factory AppState.initial() => AppState(
        busy: false,
        authState: AuthState.initial(),
        deviceState: DeviceState.initial(),
        contactsState: ContactsState.initial(),
        connectState: ConnectState.initial(),
        route: const [AppRoutes.landing],
        message: null,
        selectedTabIndex: 0,
      );

  AppState copyWith({
    bool busy,
    AuthState authState,
    DeviceState deviceState,
    ContactsState contactsState,
    ConnectState connectState,
    List<AppRoute> route,
    Message message,
    int selectedTabIndex,
  }) =>
      AppState(
        busy: busy ?? this.busy,
        authState: authState ?? this.authState,
        deviceState: deviceState ?? this.deviceState,
        contactsState: contactsState ?? this.contactsState,
        connectState: connectState ?? this.connectState,
        route: route ?? this.route,
        message: message ?? this.message,
        selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      );

  static AppState fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? AppState.initial()
          : AppState(
              busy: false,
              authState: AuthState.initial(),
              deviceState: DeviceState.fromJson(json['deviceState']),
              contactsState: ContactsState.initial(),
              connectState: ConnectState.initial(),
              route: [AppRoutes.landing],
              message: null,
              selectedTabIndex: 0,
            );

  dynamic toJson() => {
        'deviceState': deviceState.toJson(),
      };
}
