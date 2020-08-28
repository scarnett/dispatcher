import 'package:dispatcher/device/device_model.dart';
import 'package:flutter/cupertino.dart';

class LookupDeviceByInviteCodeAction {
  final String inviteCode;
  final BuildContext context;

  LookupDeviceByInviteCodeAction(
    this.inviteCode,
    this.context,
  );

  @override
  String toString() => 'LookupContactByInviteCodeAction';
}

class LookupDeviceByInviteCodeSuccessAction {
  final Device device;
  final BuildContext context;

  LookupDeviceByInviteCodeSuccessAction(
    this.device,
    this.context,
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

  ConnectDeviceAction(
    this.deviceId,
    this.connectDeviceId,
    this.context,
  );

  @override
  String toString() =>
      'ConnectDeviceAction{deviceId: $deviceId, connectDeviceId: $connectDeviceId}';
}

class ConnectDeviceSuccessAction {
  final BuildContext context;

  ConnectDeviceSuccessAction(
    this.context,
  );

  @override
  String toString() => 'ConnectDeviceSuccessAction{}';
}

class ConnectDeviceErrorAction {
  final dynamic error;
  final BuildContext context;

  ConnectDeviceErrorAction(
    this.error,
    this.context,
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
