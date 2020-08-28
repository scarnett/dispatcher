import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dispatcher/sms/sms_actions.dart';
import 'package:dispatcher/state.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

final smsMiddleware = [
  _sendSMSEpic,
];

Stream<dynamic> _sendSMSEpic(
  Stream<dynamic> actions,
  EpicStore<AppState> store,
) =>
    actions.whereType<SendSMSAction>().flatMap((payload) => Stream.fromFuture(
        FirebaseFirestore.instance
            .collection('sms')
            .add(payload.sms.toJson())
            .then<dynamic>((res) => SendSMSSuccessAction())
            .catchError((error) => SendSMSErrorAction(error))));
