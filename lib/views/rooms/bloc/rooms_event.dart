part of 'rooms_bloc.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

class FetchRoomData extends RoomsEvent {
  final User user;
  final String roomUserIdentifer;

  const FetchRoomData(
    this.user,
    this.roomUserIdentifer,
  );

  @override
  List<Object> get props => [
        user,
        roomUserIdentifer,
      ];
}

class ClearRoomData extends RoomsEvent {
  const ClearRoomData();
}
