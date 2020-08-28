import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dispatcher/utils/date_utils.dart';

class SMS {
  final String device;
  final String inboundPhone;
  final String body;
  final DateTime sentDate;

  SMS({
    this.device,
    this.inboundPhone,
    this.body,
    this.sentDate,
  });

  factory SMS.fromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    if ((snapshot == null) || !snapshot.exists) {
      return null;
    }

    return SMS(
      device: snapshot.get('device'),
      inboundPhone: snapshot.get('inbound_phone'),
      body: snapshot.get('body'),
      sentDate: toDate(snapshot.get('sent_date')),
    );
  }

  SMS copyWith({
    String device,
    String inboundPhone,
    String body,
    DateTime sentDate,
  }) =>
      SMS(
        device: device ?? this.device,
        inboundPhone: inboundPhone ?? this.inboundPhone,
        body: body ?? this.body,
        sentDate: sentDate ?? this.sentDate,
      );

  static SMS fromJson(
    dynamic json,
  ) =>
      SMS(
        device: json['device'],
        inboundPhone: json['inbound_phone'],
        body: json['body'],
        sentDate: fromIso8601String(json['sent_date']),
      );

  dynamic toJson() => {
        'device': device,
        'inbound_phone': inboundPhone,
        'body': body,
        'sent_date': toIso8601String(sentDate),
      };

  @override
  String toString() =>
      'SMS{device: $device, inbound_phone: $inboundPhone, body: $body, sent_date: $sentDate}';
}
