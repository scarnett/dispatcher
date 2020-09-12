import 'package:dispatcher/device/device_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LookupDeviceByInviteCodeAction {
  final String inviteCode;
  final BuildContext context;
  final GlobalKey<ScaffoldState> snackbarScaffoldKey;

  LookupDeviceByInviteCodeAction(
    this.inviteCode,
    this.context,
    this.snackbarScaffoldKey,
  );

  @override
  String toString() => 'LookupContactByInviteCodeAction';
}

class LookupDeviceByInviteCodeSuccessAction {
  final Device device;
  final BuildContext context;
  final GlobalKey<ScaffoldState> snackbarScaffoldKey;

  LookupDeviceByInviteCodeSuccessAction(
    this.device,
    this.context,
    this.snackbarScaffoldKey,
  );

  @override
  String toString() => 'LookupDeviceByInviteCodeSuccessAction{device: $device}';
}

class LookupDeviceByInviteCodeErrorAction {
  final dynamic error;
  final dynamic stacktrace;

  LookupDeviceByInviteCodeErrorAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'LookupDeviceByInviteCodeErrorAction{error: $error, stacktrace: $stacktrace}';
}

class CancelLookupDeviceByInviteCodeAction {}

class ConnectDeviceAction {
  final String deviceId;
  final String connectDeviceId;
  final BuildContext context;
  final GlobalKey<ScaffoldState> snackbarScaffoldKey;

  ConnectDeviceAction(
    this.deviceId,
    this.connectDeviceId,
    this.context,
    this.snackbarScaffoldKey,
  );

  @override
  String toString() =>
      'ConnectDeviceAction{deviceId: $deviceId, connectDeviceId: $connectDeviceId}';
}

class ConnectDeviceSuccessAction {
  final BuildContext context;
  final GlobalKey<ScaffoldState> snackbarScaffoldKey;

  ConnectDeviceSuccessAction(
    this.context,
    this.snackbarScaffoldKey,
  );

  @override
  String toString() => 'ConnectDeviceSuccessAction{}';
}

class ConnectDeviceErrorAction {
  final dynamic error;
  final BuildContext context;
  final GlobalKey<ScaffoldState> snackbarScaffoldKey;

  ConnectDeviceErrorAction(
    this.error,
    this.context,
    this.snackbarScaffoldKey,
  );

  @override
  String toString() => 'ConnectDeviceErrorAction{error: $error}';
}

class AlreadyConnectedAction {
  final Device device;

  AlreadyConnectedAction(
    this.device,
  );

  @override
  String toString() => 'AlreadyConnectedAction{device: $device}';
}

class CantConnectAction {
  @override
  String toString() => 'CantConnectAction{}';
}
