import 'package:dispatcher/models/models.dart';
import 'package:equatable/equatable.dart';

class Room extends Equatable {
  final List<RoomUser> users;

  Room({
    this.users,
  });

  Room copyWith({
    List<RoomUser> users,
  }) =>
      Room(
        users: users ?? this.users,
      );

  static Room fromJson(
    dynamic json,
  ) =>
      (json == null)
          ? Room()
          : Room(
              users: RoomUser.fromJsonList(json['users']),
            );

  dynamic toJson() => {
        'users': RoomUser.toJsonList(users),
      };

  @override
  List<Object> get props => [users];

  @override
  String toString() => 'Room{users: ${users.length}}';
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
  List<Object> get props => [
        room,
        user,
        preKey,
      ];

  @override
  String toString() => 'RoomUser{room: $room, user: $user, preKey: $preKey}';
}
