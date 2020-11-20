part of 'rooms_bloc.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

class FetchRoomData extends RoomsEvent {
  final List<String> users;

  const FetchRoomData(
    this.users,
  );

  @override
  List<Object> get props => [users];
}
