import 'package:dispatcher/graphql/utils.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/date_utils.dart';
import 'package:equatable/equatable.dart';

class Room extends Equatable {
  final int id;
  final String identifier;
  final List<RoomUser> users;

  Room({
    this.id,
    this.identifier,
    this.users,
  });

  Room copyWith({
    int id,
    String identifier,
    List<RoomUser> users,
  }) =>
      Room(
        id: id ?? this.id,
        identifier: identifier ?? this.identifier,
        users: users ?? this.users,
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
            );

  dynamic toJson() => {
        'id': id,
        'identifier': identifier,
        'room_users': RoomUser.toJsonList(users),
      };

  @override
  List<Object> get props => [id, identifier, users];

  @override
  String toString() =>
      'Room{id: $id, identifier: $identifier, users: ${users.length}}';
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
  final String messageIdentifier;
  final String roomIdentifier;
  final String userIdentifier;
  final List<int> message;
  final int type;
  final DateTime createdDate;

  RoomMessage({
    this.messageIdentifier,
    this.roomIdentifier,
    this.userIdentifier,
    this.message,
    this.type,
    this.createdDate,
  });

  RoomMessage copyWith({
    String messageIdentifier,
    String roomIdentifier,
    String userIdentifier,
    List<int> message,
    int type,
    DateTime createdDate,
  }) =>
      RoomMessage(
        messageIdentifier: messageIdentifier ?? this.messageIdentifier,
        roomIdentifier: roomIdentifier ?? this.roomIdentifier,
        userIdentifier: userIdentifier ?? this.userIdentifier,
        message: message ?? this.message,
        type: type ?? this.type,
        createdDate: createdDate ?? this.createdDate,
      );

  static RoomMessage fromDB(
    dynamic obj,
  ) =>
      (obj == null)
          ? RoomMessage()
          : RoomMessage(
              messageIdentifier: obj['message_identifier'],
              roomIdentifier: obj['room_identifier'],
              userIdentifier: obj['user_identifier'],
              message: parseIntArray(obj['message'].split(',')),
              type: obj['type'],
              createdDate: fromIso8601String(obj['created_date']),
            );

  static RoomMessage fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? RoomMessage()
          : RoomMessage(
              messageIdentifier: json['message_identifier'],
              roomIdentifier: json['room_identifier'],
              userIdentifier: json['user_identifier'],
              message: parseIntArray(json['message']),
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

  dynamic toDB() => {
        'message_identifier': messageIdentifier,
        'room_identifier': roomIdentifier,
        'user_identifier': userIdentifier,
        'message': message.join(','),
        'type': type,
        'created_date': toIso8601String(createdDate),
      };

  dynamic toJson() => {
        'message_identifier': messageIdentifier,
        'room_identifier': roomIdentifier,
        'user_identifier': userIdentifier,
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
  List<Object> get props => [
        messageIdentifier,
        roomIdentifier,
        userIdentifier,
        message,
        type,
        createdDate,
      ];

  @override
  String toString() =>
      'RoomMessage{message_identifier: $messageIdentifier, ' +
      'room_identifier: $roomIdentifier, ' +
      'user_identifier: $userIdentifier, ' +
      'message: $message, type: $type, created_date: $createdDate}';
}
