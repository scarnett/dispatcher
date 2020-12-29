part of 'rooms_bloc.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

class FetchRoomData extends RoomsEvent {
  final GraphQLClient client;
  final User senderUser;
  final User receiverUser;

  const FetchRoomData(
    this.client,
    this.senderUser,
    this.receiverUser,
  );

  @override
  List<Object> get props => [client, senderUser, receiverUser];
}

class SendMessage extends RoomsEvent {
  final User senderUser;
  final User receiverUser;
  final String message;

  const SendMessage(
    this.senderUser,
    this.receiverUser,
    this.message,
  );

  @override
  List<Object> get props => [senderUser, receiverUser, message];
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
