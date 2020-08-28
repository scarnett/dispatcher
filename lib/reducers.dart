import 'package:dispatcher/actions.dart';
import 'package:dispatcher/device/device_reducers.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/route/route_model.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/connect/connect_reducers.dart';
import 'package:dispatcher/views/contacts/contacts_reducers.dart';
import 'package:redux/redux.dart';

AppState appStateReducer(
  AppState state,
  dynamic action,
) =>
    AppState(
      busy: busyStatusReducer(state.busy, action),
      route: navigationReducer(state.route, action),
      message: messageReducer(state.message, action),
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

// ------------------------------------------------------- Navigation
final navigationReducer = combineReducers<List<AppRoute>>([
  TypedReducer<List<AppRoute>, NavigateReplaceAction>(
    _navigateReplace,
  ),
  TypedReducer<List<AppRoute>, NavigatePushAction>(
    _navigatePush,
  ),
  TypedReducer<List<AppRoute>, NavigatePopAction>(
    _navigatePop,
  ),
]);

List<AppRoute> _navigateReplace(
  List<AppRoute> route,
  NavigateReplaceAction action,
) =>
    [action.route];

List<AppRoute> _navigatePush(
  List<AppRoute> route,
  NavigatePushAction action,
) {
  List<AppRoute> result = List<AppRoute>.from(route);
  result..add(action.route);
  return result;
}

List<AppRoute> _navigatePop(
  List<AppRoute> route,
  NavigatePopAction action,
) {
  List<AppRoute> result = List<AppRoute>.from(route);
  result.removeLast();
  return result;
}

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
