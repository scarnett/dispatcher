import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/views/connect/connect_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';
import 'package:dispatcher/state.dart';

class ConnectViewModel {
  final String deviceId;
  final List<dynamic> connections;
  final Device lookupResult;
  final bool alreadyConnected;
  final bool cantConnect;
  final bool connected;
  final Function(String inviteCode, BuildContext contex)
      lookupDeviceByInviteCode;
  final Function(String deviceId, String connectDeviceId, BuildContext context)
      connectDevice;
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
        lookupDeviceByInviteCode: (String inviteCode, BuildContext context) =>
            store.dispatch(LookupDeviceByInviteCodeAction(inviteCode, context)),
        connectDevice:
            (String deviceId, String connectDeviceId, BuildContext context) =>
                store.dispatch(
                    ConnectDeviceAction(deviceId, connectDeviceId, context)),
        cancelConnectDevice: () =>
            store.dispatch(CancelLookupDeviceByInviteCodeAction()),
      );
}
