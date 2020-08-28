import 'package:dispatcher/keys.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/state.dart';

List<Middleware<AppState>> appMiddleware() {
  return [
    TypedMiddleware<AppState, NavigateReplaceAction>(_navigateReplace),
    TypedMiddleware<AppState, NavigatePushAction>(_navigate),
    TypedMiddleware<AppState, SendMessageAction>(_sendMessage),
  ];
}

_navigateReplace(
  Store<AppState> store,
  NavigateReplaceAction action,
  NextDispatcher next,
) {
  String routeName = action.route.name;
  if (store.state.route.last.name != routeName) {
    AppKeys.appNavKey.currentState.pushReplacementNamed(
      action.route.path,
    );
  }

  next(action);
}

_navigate(
  Store<AppState> store,
  NavigatePushAction action,
  NextDispatcher next,
) {
  String routeName = action.route.name;
  if (store.state.route.last.name != routeName) {
    AppKeys.appNavKey.currentState.pushNamed(
      action.route.path,
      arguments: action.arguments,
    );
  }

  next(action);
}

_sendMessage(
  Store<AppState> store,
  SendMessageAction action,
  NextDispatcher next,
) {
  GlobalKey<ScaffoldState> key;

  if (action.key != null) {
    key = action.key;
  } else {
    key = AppKeys.appScaffoldKey;
  }

  if (key.currentState != null) {
    key.currentState.showSnackBar(builSnackBar(action.message));
  }

  next(action);
}
