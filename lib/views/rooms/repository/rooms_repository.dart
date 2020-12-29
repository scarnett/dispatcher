import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dispatcher/models/room.dart';
import 'package:dispatcher/utils/date_utils.dart';
import 'package:rxdart/rxdart.dart';

abstract class RoomMessageRepository {
  void loadMessages(
    String roomIdentifier,
    String userIdentifier,
  );

  Stream<List<RoomMessage>> getMessages();

  void saveMessage(
    String roomIdentifier,
    String userIdentifier,
    RoomMessage message,
  );

  void deleteMessage(
    String roomIdentifier,
    String userIdentifier,
    String messageIdentifier,
  );

  void deleteMessages(
    String roomIdentifier,
    String userIdentifier,
  );

  void dispose();
}

class RoomMessageRepositoryFirestore extends RoomMessageRepository {
  StreamController<List<RoomMessage>> _messagesController = BehaviorSubject();
  final List<RoomMessage> _cache = List<RoomMessage>();

  @override
  void loadMessages(
    String roomIdentifier,
    String userIdentifier,
  ) {
    if (FirebaseFirestore.instance != null) {
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomIdentifier)
          .collection('users')
          .doc('EG6Fmt12wsby51CxfUOENg7wZaI2') // TODO! userIdentifier
          .collection('messages')
          .snapshots()
          .listen((QuerySnapshot messages) {
        _cache.clear();

        if (!_messagesController.isClosed) {
          messages.docs.forEach((QueryDocumentSnapshot messageDoc) async {
            final Map<String, dynamic> messageData = messageDoc.data();
            messageData['message_identifier'] = messageDoc.id;
            messageData['room_identifier'] = roomIdentifier;
            messageData['created_date'] =
                getNow().toIso8601String(); // TODO! remove this

            final RoomMessage message = RoomMessage.fromJson(messageData);
            _cache.add(message);
          });

          _messagesController.sink.add(_cache);
        }
      });
    }
  }

  @override
  Stream<List<RoomMessage>> getMessages() =>
      _messagesController.stream.asBroadcastStream();

  @override
  void saveMessage(
    String roomIdentifier,
    String userIdentifier,
    RoomMessage message,
  ) async {
    if (FirebaseFirestore.instance != null) {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomIdentifier)
          .collection('users')
          .doc(userIdentifier)
          .collection('messages')
          .add(message.toJson());
    }
  }

  @override
  void deleteMessage(
    String roomIdentifier,
    String userIdentifier,
    String messageIdentifier,
  ) async {
    if (FirebaseFirestore.instance != null) {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomIdentifier)
          .collection('users')
          .doc('EG6Fmt12wsby51CxfUOENg7wZaI2') // TODO! userIdentifier
          .collection('messages')
          .doc(messageIdentifier)
          .delete();
    }
  }

  @override
  void deleteMessages(
    String roomIdentifier,
    String userIdentifier,
  ) async {
    if (FirebaseFirestore.instance != null) {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomIdentifier)
          .collection('users')
          .doc(userIdentifier)
          .delete();
    }
  }

  @override
  void dispose() {
    _messagesController.close();
  }
}
