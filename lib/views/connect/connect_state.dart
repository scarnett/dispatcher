import 'package:dispatcher/device/device_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class ConnectState {
  final Device lookupResult;
  final bool alreadyConnected;
  final bool cantConnect;
  final bool connected;

  ConnectState({
    @required this.lookupResult,
    this.alreadyConnected: false,
    this.cantConnect: false,
    this.connected: false,
  });

  factory ConnectState.initial() => ConnectState(
        lookupResult: null,
        alreadyConnected: false,
        cantConnect: false,
        connected: false,
      );

  ConnectState copyWith({
    dynamic lookupResult,
    dynamic alreadyConnected,
    dynamic cantConnect,
    dynamic connected,
  }) =>
      ConnectState(
        lookupResult: lookupResult,
        alreadyConnected: alreadyConnected ?? this.alreadyConnected,
        cantConnect: cantConnect ?? this.cantConnect,
        connected: connected ?? this.connected,
      );
}
