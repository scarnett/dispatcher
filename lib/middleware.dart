import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/state.dart';

List<Middleware<AppState>> appMiddleware() {
  return [
    TypedMiddleware<AppState, SendMessageAction>(_sendMessage),
  ];
}

_sendMessage(
  Store<AppState> store,
  SendMessageAction action,
  NextDispatcher next,
) {
  GlobalKey<ScaffoldState> key;

  if (action.key != null) {
    key = action.key;
  }

  if (key.currentState != null) {
    key.currentState.showSnackBar(buildSnackBar(action.message));
  }

  next(action);
}
