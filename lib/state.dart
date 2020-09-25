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
    ConnectState connectState,
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
