import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/device/device_services.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/connect/connect_actions.dart';
import 'package:dispatcher/views/connect/connect_keys.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

final connectMiddleware = [
  _lookupDeviceByInviteCodeEpic,
  _lookupDeviceByInviteCodeSuccessEpic,
  _connectDeviceEpic,
  _connectDeviceSuccessEpic,
  _connectDeviceErrorEpic,
];

Stream<dynamic> _lookupDeviceByInviteCodeEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<LookupDeviceByInviteCodeAction>().switchMap(
        (LookupDeviceByInviteCodeAction action) =>
            getDeviceByInviteCode(action.inviteCode)
                .map((Device device) {
                  if (device != null) {
                    // Check to see if the requested connection device matches
                    // the current user device id.
                    // i.e. cant connect to your self
                    if (store.state.deviceState.device.id == device.id) {
                      return CantConnectAction();
                      // Check to see if we're already connected to this device
                    } else if ((store.state.deviceState.connections.singleWhere(
                            (DeviceConnection connection) =>
                                connection.deviceId == device.id,
                            orElse: () => null)) !=
                        null) {
                      return AlreadyConnectedAction(device);
                    }
                  }

                  return LookupDeviceByInviteCodeSuccessAction(
                    device,
                    action.context,
                  );
                })
                .takeUntil(actions.where(
                    (action) => action is CancelLookupDeviceByInviteCodeAction))
                .doOnError((error, stacktrace) =>
                    LookupDeviceByInviteCodeErrorAction(error, stacktrace)));

Stream<dynamic> _lookupDeviceByInviteCodeSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions
        .whereType<LookupDeviceByInviteCodeSuccessAction>()
        .map((LookupDeviceByInviteCodeSuccessAction action) {
      if (action.device == null) {
        return SendMessageAction(
          Message(
            text: AppLocalizations.of(action.context).connectionNotFoundText,
            type: MessageType.ERROR,
          ),
          key: ConnectKeys.connectScaffoldKey,
        );
      }

      return SendMessageAction(
        Message(
          text: AppLocalizations.of(action.context).connectionFoundText,
          type: MessageType.SUCCESS,
        ),
        key: ConnectKeys.connectScaffoldKey,
      );
    });

Stream<dynamic> _connectDeviceEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<ConnectDeviceAction>().flatMap((payload) =>
        Stream.fromFuture(FirebaseFirestore.instance
            .collection('devices')
            .doc(payload.deviceId)
            .collection('connections')
            .add({
              'device_id': payload.deviceId,
            })
            .then<dynamic>((res) => ConnectDeviceSuccessAction(payload.context))
            .catchError(
                (error) => ConnectDeviceErrorAction(error, payload.context))));

Stream<dynamic> _connectDeviceSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions
        .whereType<ConnectDeviceSuccessAction>()
        .map((ConnectDeviceSuccessAction action) {
      if (action.context != null) {
        return SendMessageAction(
          Message(
            text: AppLocalizations.of(action.context).connectSuccess,
            type: MessageType.SUCCESS,
          ),
          key: ConnectKeys.connectScaffoldKey,
        );
      }

      return {};
    });

Stream<dynamic> _connectDeviceErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions
        .whereType<ConnectDeviceErrorAction>()
        .map((ConnectDeviceErrorAction action) {
      if (action.context != null) {
        return SendMessageAction(
          Message(
            text: AppLocalizations.of(action.context).error,
            type: MessageType.ERROR,
          ),
          key: ConnectKeys.connectScaffoldKey,
        );
      }

      return {};
    });
