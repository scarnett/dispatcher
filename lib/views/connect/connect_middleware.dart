final connectMiddleware = [
  //_lookupDeviceByInviteCodeEpic,
  //_lookupDeviceByInviteCodeSuccessEpic,
  //_connectDeviceEpic,
  //_connectDeviceSuccessEpic,
  //_connectDeviceErrorEpic,
];

/*
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
                    action.snackbarScaffoldKey,
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
          key: action.snackbarScaffoldKey,
        );
      }

      return SendMessageAction(
        Message(
          text: AppLocalizations.of(action.context).connectionFoundText,
          type: MessageType.SUCCESS,
        ),
        key: action.snackbarScaffoldKey,
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
            .then<dynamic>((res) => ConnectDeviceSuccessAction(
                payload.context, payload.snackbarScaffoldKey))
            .catchError((error) => ConnectDeviceErrorAction(
                error, payload.context, payload.snackbarScaffoldKey))));

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
          key: action.snackbarScaffoldKey,
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
          key: action.snackbarScaffoldKey,
        );
      }

      return {};
    });
*/
