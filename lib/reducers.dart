import 'package:dispatcher/actions.dart';
import 'package:dispatcher/device/device_reducers.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/auth/auth_reducers.dart';
import 'package:dispatcher/views/connect/connect_reducers.dart';
import 'package:dispatcher/views/contacts/contacts_reducers.dart';
import 'package:redux/redux.dart';

AppState appStateReducer(
  AppState state,
  dynamic action,
) =>
    AppState(
      busy: busyStatusReducer(state.busy, action),
      message: messageReducer(state.message, action),
      selectedTabIndex: selectedTabIndexReducer(state.selectedTabIndex, action),
      authState: authReducer(state.authState, action),
      deviceState: deviceReducer(state.deviceState, action),
      contactsState: contactsReducer(state.contactsState, action),
      connectState: connectReducer(state.connectState, action),
    );

// ------------------------------------------------------- Busy Status
final busyStatusReducer = combineReducers<bool>([
  TypedReducer<bool, SetAppBusyStatusAction>(
    _setBusyStatus,
  ),
]);

bool _setBusyStatus(
  bool oldStatus,
  SetAppBusyStatusAction action,
) =>
    action.status;

// ------------------------------------------------------- Message
final messageReducer = combineReducers<Message>([
  TypedReducer<Message, SendMessageAction>(
    _sendMessage,
  ),
  TypedReducer<Message, ClearMessageAction>(
    _clearMessage,
  ),
]);

Message _sendMessage(
  Message message,
  SendMessageAction action,
) {
  return action.message;
}

Message _clearMessage(
  Message message,
  ClearMessageAction action,
) {
  return null;
}

// ------------------------------------------------------- Selected Tab Index
final selectedTabIndexReducer = combineReducers<int>([
  TypedReducer<int, SetSelectedTabIndexAction>(
    _setSelectedTabIndex,
  ),
]);

int _setSelectedTabIndex(
  int selectedTabIndex,
  SetSelectedTabIndexAction action,
) {
  return action.selectedTabIndex;
}
