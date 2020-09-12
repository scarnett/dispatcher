import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/views/connect/connect_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:dispatcher/state.dart';

class ConnectViewModel {
  final String deviceId;
  final List<dynamic> connections;
  final Device lookupResult;
  final bool alreadyConnected;
  final bool cantConnect;
  final bool connected;
  final Function(String inviteCode, BuildContext contex,
      GlobalKey<ScaffoldState> snackbarScaffoldKey) lookupDeviceByInviteCode;
  final Function(String deviceId, String connectDeviceId, BuildContext context,
      GlobalKey<ScaffoldState> snackbarScaffoldKey) connectDevice;
  final Function() cancelConnectDevice;

  ConnectViewModel({
    this.deviceId,
    this.connections,
    this.lookupResult,
    this.alreadyConnected,
    this.cantConnect,
    this.connected,
    this.lookupDeviceByInviteCode,
    this.connectDevice,
    this.cancelConnectDevice,
  });

  static ConnectViewModel fromStore(
    Store<AppState> store,
  ) =>
      ConnectViewModel(
        deviceId: store.state.deviceState.device.id,
        connections: store.state.deviceState.connections,
        lookupResult: store.state.connectState.lookupResult,
        alreadyConnected: store.state.connectState.alreadyConnected,
        cantConnect: store.state.connectState.cantConnect,
        connected: store.state.connectState.connected,
        lookupDeviceByInviteCode: (String inviteCode, BuildContext context,
                GlobalKey<ScaffoldState> snackbarScaffoldKey) =>
            store.dispatch(LookupDeviceByInviteCodeAction(
                inviteCode, context, snackbarScaffoldKey)),
        connectDevice: (String deviceId,
                String connectDeviceId,
                BuildContext context,
                GlobalKey<ScaffoldState> snackbarScaffoldKey) =>
            store.dispatch(ConnectDeviceAction(
                deviceId, connectDeviceId, context, snackbarScaffoldKey)),
        cancelConnectDevice: () =>
            store.dispatch(CancelLookupDeviceByInviteCodeAction()),
      );
}
