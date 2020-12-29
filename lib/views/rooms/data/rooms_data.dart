import 'package:dispatcher/data/database.dart';
import 'package:dispatcher/models/room.dart';
import 'package:dispatcher/utils/crypt_utils.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:sqflite/sqflite.dart';

// @see https://github.com/Erigitic/flutter-streams/tree/master/lib
class RoomsDBProvider extends DispatcherDBProvider {
  RoomsDBProvider._();

  static final RoomsDBProvider db = RoomsDBProvider._();

  Future<void> addRoomMessages(
    SessionCipher sessionCipher,
    List<RoomMessage> messages,
  ) async {
    final Database db = await database;
    Batch batch = db.batch();

    for (RoomMessage message in messages) {
      print(message.message);
      String result = decryptMessage(
        sessionCipher,
        message.message,
      );

      dynamic json = message.toDB();
      json['message'] = result;

      batch.insert('room_messages', json);
    }

    await batch.commit(noResult: true);
  }

  Future<int> addRoomMessage(
    RoomMessage message,
  ) async {
    final Database db = await database;
    int res = await db.insert('room_messages', message.toDB());
    return res;
  }

  Future<List<RoomMessage>> getRoomMessages(
    String roomIdentifier,
  ) async {
    final Database db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'room_messages',
      where: 'room_identifier = ?',
      whereArgs: [
        roomIdentifier,
      ],
    );

    List<RoomMessage> messages = (res != null) && res.isNotEmpty
        ? res.map((message) => RoomMessage.fromDB(message)).toList()
        : [];

    return messages;
  }

  Future<RoomMessage> getRoomMessage(
    String messageIdentifier,
    String roomIdentifier,
  ) async {
    final Database db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'room_messages',
      where: 'message_identifier = ? AND room_identifier = ?',
      whereArgs: [
        messageIdentifier,
        roomIdentifier,
      ],
    );

    return res.isNotEmpty ? RoomMessage.fromDB(res.first) : null;
  }

  Future<void> deleteRoomMessage(
    String messageIdentifier,
    String roomIdentifier,
  ) async {
    final Database db = await database;
    db.delete(
      'room_messages',
      where: 'message_identifier = ? AND room_identifier = ?',
      whereArgs: [
        messageIdentifier,
        roomIdentifier,
      ],
    );
  }
}
