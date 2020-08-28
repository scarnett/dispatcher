import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/device/device_actions.dart';
import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/device/device_services.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/sms/sms_actions.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/settings/settings_keys.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

final deviceMiddleware = [
  _requestDeviceEpic,
  _requestDeviceConnectionsEpic,
  _registerDeviceEpic,
  _loadedDeviceEpic,
  _saveDeviceEpic,
  _saveDeviceSuccessEpic,
  _saveDeviceErrorEpic,
  _savePINVerificationCodeEpic,
  _savePINVerificationCodeSuccessEpic,
  _clearPINVerificationCodeEpic,
  _savePINCodeEpic,
];

Stream<dynamic> _requestDeviceEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<RequestDeviceAction>().switchMap(
        (RequestDeviceAction action) => getDevice(action.identifier)
            .map((Device device) {
              if (device == null) {
                return RegisterDeviceAction(action.identifier);
              }

              return RequestDeviceSuccessAction(device);
            })
            .takeUntil(
                actions.where((action) => action is CancelRequestDeviceAction))
            .doOnError((error, stacktrace) =>
                RequestDeviceErrorAction(error, stacktrace)));

Stream<dynamic> _requestDeviceConnectionsEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<RequestDeviceConnectionsAction>().switchMap(
        (RequestDeviceConnectionsAction action) =>
            getDeviceConnections(action.deviceId)
                .map(
                    (List<DeviceConnection> connections) =>
                        RequestDeviceConnectionsSuccessAction(connections))
                .takeUntil(actions.where(
                    (action) => action is CancelRequestDeviceConnectionsAction))
                .doOnError((error, stacktrace) =>
                    RequestDeviceConnectionsErrorAction(error, stacktrace)));

Stream<dynamic> _registerDeviceEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions
        .whereType<RegisterDeviceAction>()
        .flatMap((RegisterDeviceAction action) {
      Device device = Device(
        identifier: action.identifier,
      );

      return Stream.fromFuture(
        FirebaseFirestore.instance
            .collection('devices')
            .add(device.toJson())
            .then<dynamic>((res) => RegisterDeviceSuccessAction(res.id, device))
            .catchError((error) => RegisterDeviceErrorAction(error)),
      );
    });

Stream<dynamic> _loadedDeviceEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<LoadedDeviceAction>().map(
        (LoadedDeviceAction action) => NavigateReplaceAction(AppRoutes.home));

Stream<dynamic> _saveDeviceEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<SaveDeviceAction>().flatMap((payload) =>
        Stream.fromFuture(FirebaseFirestore.instance
            .collection('devices')
            .doc(payload.documentId)
            .set(
              payload.data,
              SetOptions(merge: true),
            )
            .then<dynamic>(
                (res) => SaveDeviceSuccessAction(context: payload.context))
            .catchError((error) =>
                SaveDeviceErrorAction(error, context: payload.context))));

Stream<dynamic> _saveDeviceSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<SaveDeviceSuccessAction>().map(
          (SaveDeviceSuccessAction action) => (action.context != null)
              ? SendMessageAction(
                  Message(
                    text: AppLocalizations.of(action.context).saved,
                    type: MessageType.SUCCESS,
                  ),
                  key: SettingsKeys.settingsScaffoldKey,
                )
              : {},
        );

Stream<dynamic> _saveDeviceErrorEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions
        .whereType<SaveDeviceErrorAction>()
        .map((SaveDeviceErrorAction action) {
      if (action.context != null) {
        return (SaveDeviceSuccessAction action) => (action.context != null)
            ? SendMessageAction(
                Message(
                  text: AppLocalizations.of(action.context).error,
                  type: MessageType.ERROR,
                ),
                key: SettingsKeys.settingsScaffoldKey,
              )
            : {};
      }

      return {};
    });

Stream<dynamic> _savePINVerificationCodeEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<SavePINVerificationCodeAction>().flatMap((payload) =>
        Stream.fromFuture(FirebaseFirestore.instance
            .collection('devices')
            .doc(payload.documentId)
            .set(
              {
                'user': {
                  'pin': {
                    'verification_code': payload.verificationCode,
                    'verification_expire_date': payload.verificationExpireDate,
                  },
                },
              },
              SetOptions(merge: true),
            )
            .then<dynamic>(
                (res) => SavePINVerificationCodeSuccessAction(payload.sms))
            .catchError((error) => SavePINVerificationCodeErrorAction(error))));

Stream<dynamic> _savePINVerificationCodeSuccessEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<SavePINVerificationCodeSuccessAction>().map(
        (SavePINVerificationCodeSuccessAction action) =>
            SendSMSAction(action.sms));

Stream<dynamic> _clearPINVerificationCodeEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<ClearPINVerificationCodeAction>().flatMap((payload) =>
        Stream.fromFuture(FirebaseFirestore.instance
            .collection('devices')
            .doc(payload.documentId)
            .set(
              {
                'user': {
                  'pin': {
                    'verification_code': FieldValue.delete(),
                    'verification_expire_date': FieldValue.delete(),
                  },
                },
              },
              SetOptions(merge: true),
            )
            .then<dynamic>((res) => ClearPINVerificationCodeSuccessAction())
            .catchError(
                (error) => ClearPINVerificationCodeErrorAction(error))));

Stream<dynamic> _savePINCodeEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions
        .whereType<SavePINCodeAction>()
        .flatMap((payload) => Stream.fromFuture(FirebaseFirestore.instance
            .collection('devices')
            .doc(payload.documentId)
            .set(
              {
                'user': {
                  'pin': {
                    'pin_code': payload.pinCode,
                    'verification_code': FieldValue.delete(),
                    'verification_expire_date': FieldValue.delete(),
                  },
                },
              },
              SetOptions(merge: true),
            )
            .then<dynamic>((res) => SavePINCodeSuccessAction())
            .catchError((error) => SavePINCodeErrorAction(error))));
