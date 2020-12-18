part of 'rooms_bloc.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

class FetchRoomData extends RoomsEvent {
  final GraphQLClient client;
  final User user;
  final String roomUserIdentifer;

  const FetchRoomData(
    this.client,
    this.user,
    this.roomUserIdentifer,
  );

  @override
  List<Object> get props => [client, user, roomUserIdentifer];
}

class SendMessage extends RoomsEvent {
  final String user;
  final String message;

  const SendMessage(
    this.user,
    this.message,
  );

  @override
  List<Object> get props => [user, message];
}

class AddMessages extends RoomsEvent {
  final List<dynamic> messages;

  const AddMessages(
    this.messages,
  );

  @override
  List<Object> get props => [messages];
}

class AddMessage extends RoomsEvent {
  final dynamic message;

  const AddMessage(
    this.message,
  );

  @override
  List<Object> get props => [message];
}

class ClearRoomData extends RoomsEvent {
  const ClearRoomData();
}

class SetSessionStatus extends RoomsEvent {
  final RoomSessionStatus sessionStatus;

  const SetSessionStatus(
    this.sessionStatus,
  );

  @override
  List<Object> get props => [sessionStatus];
}
