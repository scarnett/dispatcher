import 'dart:io';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/device/device_actions.dart';
import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/route/route_model.dart';
import 'package:dispatcher/sms/sms_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';
import 'package:dispatcher/state.dart';

class DeviceViewModel {
  final bool busy;
  final Device device;
  final Function(String identifier) requestDevice;
  final Function(String deviceId) requestDeviceConnections;
  final Function(String identifier) registerDevice;
  final Function() loadedDevice;
  final Function(String documentId, dynamic data, {BuildContext context})
      saveDevice;
  final Function(String documentId, String pinVerificationCode,
      DateTime verificationExpireDate, SMS sms) savePINVerificationCode;
  final Function(String documentId) clearPINVerificationCode;
  final Function(String documentId, String pin) savePINCode;
  final Function(String documentId, File avatarFile, {BuildContext context})
      uploadAvatar;

  DeviceViewModel({
    this.busy,
    this.device,
    this.requestDevice,
    this.requestDeviceConnections,
    this.registerDevice,
    this.loadedDevice,
    this.saveDevice,
    this.savePINVerificationCode,
    this.clearPINVerificationCode,
    this.savePINCode,
    this.uploadAvatar,
  });

  static DeviceViewModel fromStore(
    Store<AppState> store,
  ) =>
      DeviceViewModel(
        busy: store.state.busy,
        device: store.state.deviceState.device,
        requestDevice: (identifier) =>
            store.dispatch(RequestDeviceAction(identifier)),
        requestDeviceConnections: (deviceId) =>
            store.dispatch(RequestDeviceConnectionsAction(deviceId)),
        registerDevice: (identifier) =>
            store.dispatch(RegisterDeviceAction(identifier)),
        loadedDevice: () => store.dispatch(LoadedDeviceAction()),
        saveDevice: (documentId, data, {context}) => store
            .dispatch(SaveDeviceAction(documentId, data, context: context)),
        savePINVerificationCode:
            (documentId, verificationCode, verificationExpireDate, sms) =>
                store.dispatch(SavePINVerificationCodeAction(
                    documentId, verificationCode, verificationExpireDate, sms)),
        clearPINVerificationCode: (documentId) =>
            store.dispatch(ClearPINVerificationCodeAction(documentId)),
        savePINCode: (documentId, pinCode) =>
            store.dispatch(SavePINCodeAction(documentId, pinCode)),
        uploadAvatar: (documentId, avatarFile, {context}) => store.dispatch(
            UploadAvatarAction(documentId, avatarFile, context: context)),
      );
}
