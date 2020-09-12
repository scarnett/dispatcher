import 'package:flutter/cupertino.dart';

class FetchDeviceAction {
  final String identifier;

  FetchDeviceAction(
    this.identifier,
  );

  @override
  String toString() => 'FetchDeviceSuccessAction{identifier: $identifier}';
}

class FetchDeviceSuccessAction {
  final dynamic data;

  FetchDeviceSuccessAction(
    this.data,
  );

  @override
  String toString() => 'FetchDeviceSuccessAction{}';
}

class FetchDeviceErrorAction {
  final dynamic error;
  final BuildContext context;

  FetchDeviceErrorAction(
    this.error, {
    this.context,
  });

  @override
  String toString() => 'FetchDeviceErrorAction{error: $error}';
}

/*
class RequestDeviceAction {
  final String identifier;

  RequestDeviceAction(
    this.identifier,
  );

  @override
  String toString() => 'RequestDeviceAction{identifier: $identifier}';
}

class RequestDeviceSuccessAction {
  final Device device;

  RequestDeviceSuccessAction(
    this.device,
  );

  @override
  String toString() => 'RequestDeviceSuccessAction{device: $device}';
}

class RequestDeviceErrorAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestDeviceErrorAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestDeviceErrorAction{error: $error, stacktrace: $stacktrace}';
}

class CancelRequestDeviceAction {}

class RequestDeviceConnectionsAction {
  final String deviceId;

  RequestDeviceConnectionsAction(
    this.deviceId,
  );

  @override
  String toString() => 'RequestDeviceConnectionsAction{deviceId: $deviceId}';
}

class RequestDeviceConnectionsSuccessAction {
  final List<DeviceConnection> connections;

  RequestDeviceConnectionsSuccessAction(
    this.connections,
  );

  @override
  String toString() =>
      'RequestDeviceConnectionsSuccessAction{connections: $connections}';
}

class RequestDeviceConnectionsErrorAction {
  final dynamic error;
  final dynamic stacktrace;

  RequestDeviceConnectionsErrorAction(
    this.error,
    this.stacktrace,
  );

  @override
  String toString() =>
      'RequestDeviceConnectionsErrorAction{error: $error, stacktrace: $stacktrace}';
}

class CancelRequestDeviceConnectionsAction {}

class RegisterDeviceAction {
  final String identifier;

  RegisterDeviceAction(
    this.identifier,
  );

  @override
  String toString() => 'RegisterDeviceAction{identifier: $identifier}';
}

class LoadedDeviceAction {
  @override
  String toString() => 'LoadedDeviceAction{}';
}

class RegisterDeviceSuccessAction {
  final String id;
  final Device device;

  RegisterDeviceSuccessAction(
    this.id,
    this.device,
  );

  @override
  String toString() => 'RegisterDeviceSuccessAction{id: $id, device: $device}';
}

class RegisterDeviceErrorAction {
  final dynamic error;

  RegisterDeviceErrorAction(
    this.error,
  );

  @override
  String toString() => 'RegisterDeviceErrorAction{error: $error}';
}

class SavePINVerificationCodeAction {
  final String documentId;
  final String verificationCode;
  final DateTime verificationExpireDate;
  final SMS sms;

  SavePINVerificationCodeAction(
    this.documentId,
    this.verificationCode,
    this.verificationExpireDate,
    this.sms,
  );

  @override
  String toString() => 'SavePINVerificationCodeAction{documentId: $documentId}';
}

class SavePINVerificationCodeSuccessAction {
  final SMS sms;

  SavePINVerificationCodeSuccessAction(
    this.sms,
  );

  @override
  String toString() => 'SavePINVerificationCodeSuccessAction{}';
}

class SavePINVerificationCodeErrorAction {
  final dynamic error;

  SavePINVerificationCodeErrorAction(
    this.error,
  );

  @override
  String toString() => 'SavePINVerificationCodeErrorAction{error: $error}';
}

class ClearPINVerificationCodeAction {
  final String documentId;

  ClearPINVerificationCodeAction(
    this.documentId,
  );

  @override
  String toString() =>
      'ClearPINVerificationCodeAction{documentId: $documentId}';
}

class ClearPINVerificationCodeSuccessAction {
  @override
  String toString() => 'ClearPINVerificationCodeSuccessAction{}';
}

class ClearPINVerificationCodeErrorAction {
  final dynamic error;

  ClearPINVerificationCodeErrorAction(
    this.error,
  );

  @override
  String toString() => 'ClearPINVerificationCodeErrorAction{error: $error}';
}

class SavePINCodeAction {
  final String documentId;
  final String pinCode;

  SavePINCodeAction(
    this.documentId,
    this.pinCode,
  );

  @override
  String toString() => 'SavePINCodeAction{documentId: $documentId}';
}

class SavePINCodeSuccessAction {
  @override
  String toString() => 'SavePINCodeSuccessAction{}';
}

class SavePINCodeErrorAction {
  final dynamic error;

  SavePINCodeErrorAction(
    this.error,
  );

  @override
  String toString() => 'SavePINCodeErrorAction{error: $error}';
}

class UploadAvatarAction {
  final String documentId;
  final File avatarFile;
  final BuildContext context;

  UploadAvatarAction(
    this.documentId,
    this.avatarFile, {
    this.context,
  });

  @override
  String toString() =>
      'UploadAvatarAction{documentId: $documentId, avatar: ${avatarFile.path}}';
}

class UploadAvatarSuccessAction {
  final BuildContext context;

  UploadAvatarSuccessAction({
    this.context,
  });

  @override
  String toString() => 'UploadAvatarSuccessAction{}';
}

class UploadAvatarErrorAction {
  final dynamic error;
  final BuildContext context;

  UploadAvatarErrorAction(
    this.error, {
    this.context,
  });

  @override
  String toString() => 'UploadAvatarErrorAction{error: $error}';
}
*/
