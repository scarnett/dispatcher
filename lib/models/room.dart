import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/date_utils.dart';
import 'package:equatable/equatable.dart';

class Room extends Equatable {
  final int id;
  final String identifier;
  final List<RoomUser> users;
  final List<RoomMessage> messages;

  Room({
    this.id,
    this.identifier,
    this.users,
    this.messages,
  });

  Room copyWith({
    int id,
    String identifier,
    List<RoomUser> users,
    List<RoomMessage> messages,
  }) =>
      Room(
        id: id ?? this.id,
        identifier: identifier ?? this.identifier,
        users: users ?? this.users,
        messages: messages ?? this.messages,
      );

  static Room fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? Room()
          : Room(
              id: json['id'],
              identifier: json['identifier'],
              users: RoomUser.fromJsonList(json['room_users']),
              messages: RoomMessage.fromJsonList(json['room_messages']),
            );

  dynamic toJson() => {
        'id': id,
        'identifier': identifier,
        'room_users': RoomUser.toJsonList(users),
        'room_messages': RoomMessage.toJsonList(messages),
      };

  @override
  List<Object> get props => [id, identifier, users, messages];

  @override
  String toString() =>
      'Room{id: $id, identifier: $identifier, users: ${users.length}, ' +
      'messages: ${messages.length}}';
}

class RoomUser extends Equatable {
  final Room room;
  final User user;
  final UserPreKey preKey;

  RoomUser({
    this.room,
    this.user,
    this.preKey,
  });

  RoomUser copyWith({
    Room room,
    User user,
    UserPreKey preKey,
  }) =>
      RoomUser(
        room: room ?? this.room,
        user: user ?? this.user,
        preKey: preKey ?? this.preKey,
      );

  static RoomUser fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? RoomUser()
          : RoomUser(
              room: Room.fromJson(json['room']),
              user: User.fromJson(json['user']),
              preKey: UserPreKey.fromJson(json['preKey']),
            );

  static List<RoomUser> fromJsonList(
    dynamic json,
  ) =>
      (json == null)
          ? []
          : List<dynamic>.from(json)
              .map((dynamic userJson) => RoomUser.fromJson(userJson))
              .toList();

  dynamic toJson() => {
        'room': room.toJson(),
        'user': user.toJson(),
        'preKey': preKey.toJson(),
      };

  static List<dynamic> toJsonList(
    List<RoomUser> users,
  ) =>
      (users == null)
          ? []
          : users.map((RoomUser user) => user.toJson()).toList();

  @override
  List<Object> get props => [room, user, preKey];

  @override
  String toString() => 'RoomUser{room: $room, user: $user, preKey: $preKey}';
}

class RoomMessage extends Equatable {
  final String user;
  final String message;
  final int type;
  final DateTime createdDate;

  RoomMessage({
    this.user,
    this.message,
    this.type,
    this.createdDate,
  });

  RoomMessage copyWith({
    String user,
    String message,
    int type,
    DateTime createdDate,
  }) =>
      RoomMessage(
        user: user ?? this.user,
        message: message ?? this.message,
        type: type ?? this.type,
        createdDate: createdDate ?? this.createdDate,
      );

  static RoomMessage fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? RoomMessage()
          : RoomMessage(
              user: json['user_identifier'],
              message: json['message'],
              type: json['type'],
              createdDate: fromIso8601String(json['created_date']),
            );

  static List<RoomMessage> fromJsonList(
    dynamic json,
  ) =>
      (json == null)
          ? []
          : List<dynamic>.from(json)
              .map((dynamic userJson) => RoomMessage.fromJson(userJson))
              .toList();

  dynamic toJson() => {
        'user_identifier': user,
        'message': message,
        'type': type,
        'created_date': toIso8601String(createdDate),
      };

  static List<dynamic> toJsonList(
    List<RoomMessage> users,
  ) =>
      (users == null)
          ? []
          : users.map((RoomMessage user) => user.toJson()).toList();

  @override
  List<Object> get props => [user, message, type, createdDate];

  @override
  String toString() =>
      'RoomMessage{user_identifier: $user, message: $message, type: $type, ' +
      'created_date: $createdDate}';
}
