import 'package:dispatcher/model.dart';
import 'package:dispatcher/route/route_model.dart';
import 'package:dispatcher/views/connect/connect_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class AppState {
  final ConnectState connectState;

  AppState({this.connectState});

  factory AppState.initial() => AppState(
        connectState: ConnectState.initial(),
      );

  AppState copyWith({
    bool busy,
    ConnectState connectState,
    List<AppRoute> route,
    Message message,
  }) =>
      AppState(
        connectState: connectState ?? this.connectState,
      );

  static AppState fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? AppState.initial()
          : AppState(
              connectState: ConnectState.initial(),
            );
}
