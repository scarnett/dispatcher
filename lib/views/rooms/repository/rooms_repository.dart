import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dispatcher/models/room.dart';
import 'package:rxdart/rxdart.dart';

abstract class RoomMessageRepository {
  Stream<List<RoomMessage>> messages();

  void sendMessage(
    String roomIdentifier,
    RoomMessage message,
  );

  void refreshMessages(
    String roomId,
  );

  void dispose();
}

class RoomMessageRepositoryFirestore extends RoomMessageRepository {
  StreamController<List<RoomMessage>> _messagesController = BehaviorSubject();
  final List<RoomMessage> _cache = List<RoomMessage>();

  @override
  void dispose() {
    _messagesController.close();
  }

  @override
  void sendMessage(
    String roomIdentifier,
    RoomMessage message,
  ) async {
    if (FirebaseFirestore.instance != null) {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomIdentifier)
          .collection('messages')
          .add(message.toJson());
    }
  }

  @override
  void refreshMessages(
    String roomId,
  ) {
    if (FirebaseFirestore.instance != null) {
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .snapshots()
          .listen((QuerySnapshot messages) {
        _cache.clear();

        if (!_messagesController.isClosed) {
          messages.docs.forEach((QueryDocumentSnapshot messageDoc) {
            final Map<String, dynamic> messageData = messageDoc.data();
            _cache.add(RoomMessage.fromJson(messageData));
          });

          _messagesController.sink.add(_cache);
        }
      });
    }
  }

  @override
  Stream<List<RoomMessage>> messages() =>
      _messagesController.stream.asBroadcastStream();
}
