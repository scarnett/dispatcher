import 'package:dispatcher/model.dart';
import 'package:dispatcher/route/route_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigateReplaceAction {
  final AppRoute route;

  NavigateReplaceAction(
    this.route,
  );

  @override
  String toString() => 'NavigateReplaceAction{route: ${route.path}}';
}

class NavigatePushAction {
  final AppRoute route;
  final Object arguments;

  NavigatePushAction(
    this.route, {
    this.arguments,
  });

  @override
  String toString() =>
      'NavigatePushAction{route: ${route.path}, arguments: $arguments}';
}

class NavigatePopAction {
  @override
  String toString() => 'NavigatePopAction';
}

class SetAppBusyStatusAction {
  final bool status;

  SetAppBusyStatusAction(
    this.status,
  );

  @override
  String toString() => 'SetAppBusyStatusAction{status: $status}';
}

class SendMessageAction {
  final Message message;
  final GlobalKey<ScaffoldState> key;

  SendMessageAction(
    this.message, {
    this.key,
  });

  @override
  String toString() => 'SendMessageAction{message: $message}';
}

class ClearMessageAction {
  ClearMessageAction();

  @override
  String toString() => 'ClearMessageAction';
}

class SetSelectedTabIndexAction {
  final int selectedTabIndex;

  SetSelectedTabIndexAction(this.selectedTabIndex);

  @override
  String toString() =>
      'SetSelectedTabIndexAction{selectedTabIndex: $selectedTabIndex}';
}
