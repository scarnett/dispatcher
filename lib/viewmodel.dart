import 'package:dispatcher/actions.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/route/route_model.dart';
import 'package:dispatcher/state.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

class AppViewModel {
  final List<AppRoute> route;
  final Message message;
  final Function(AppRoute) navigate;
  final Function(Message) sendMessage;
  final Function() clearMessage;

  AppViewModel({
    @required this.route,
    @required this.message,
    @required this.navigate,
    @required this.sendMessage,
    @required this.clearMessage,
  });

  static AppViewModel fromStore(
    Store<AppState> store,
  ) =>
      AppViewModel(
        route: store.state.route,
        message: store.state.message,
        navigate: (routeName) =>
            store.dispatch(NavigateReplaceAction(routeName)),
        sendMessage: (message) => store.dispatch(SendMessageAction(message)),
        clearMessage: () => store.dispatch(ClearMessageAction()),
      );
}
