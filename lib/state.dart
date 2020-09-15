import 'package:dispatcher/model.dart';
import 'package:dispatcher/route/route_model.dart';
import 'package:dispatcher/views/connect/connect_state.dart';
import 'package:dispatcher/views/contacts/contacts_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class AppState {
  final ContactsState contactsState;
  final ConnectState connectState;

  AppState({this.contactsState, this.connectState});

  factory AppState.initial() => AppState(
        contactsState: ContactsState.initial(),
        connectState: ConnectState.initial(),
      );

  AppState copyWith({
    bool busy,
    ContactsState contactsState,
    ConnectState connectState,
    List<AppRoute> route,
    Message message,
  }) =>
      AppState(
        contactsState: contactsState ?? this.contactsState,
        connectState: connectState ?? this.connectState,
      );

  static AppState fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? AppState.initial()
          : AppState(
              contactsState: ContactsState.initial(),
              connectState: ConnectState.initial(),
            );
}
