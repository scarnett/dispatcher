import 'package:dispatcher/sms/sms_model.dart';

class SendSMSAction {
  final SMS sms;

  SendSMSAction(
    this.sms,
  );

  @override
  String toString() => 'SendSMSAction{sms: $sms}';
}

class SendSMSSuccessAction {
  @override
  String toString() => 'SendSMS{}';
}

class SendSMSErrorAction {
  final dynamic error;

  SendSMSErrorAction(
    this.error,
  );

  @override
  String toString() => 'SendSMSErrorAction{error: $error}';
}
