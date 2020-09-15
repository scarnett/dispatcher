import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/connect/connect_reducers.dart';
import 'package:dispatcher/views/contacts/contacts_reducers.dart';

AppState appStateReducer(
  AppState state,
  dynamic action,
) =>
    AppState(
      contactsState: contactsReducer(state.contactsState, action),
      connectState: connectReducer(state.connectState, action),
    );
