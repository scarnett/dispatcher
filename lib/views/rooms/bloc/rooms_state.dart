part of 'rooms_bloc.dart';

@immutable
class RoomsState extends Equatable {
  final Room activeRoom;
  final RoomSessionStatus sessionStatus;
  final signal.SessionCipher sessionCipher;

  RoomsState({
    this.activeRoom,
    this.sessionStatus: RoomSessionStatus.NONE,
    this.sessionCipher,
  });

  const RoomsState._({
    this.activeRoom,
    this.sessionStatus,
    this.sessionCipher,
  });

  const RoomsState.initial() : this._();

  RoomsState copyWith({
    Room activeRoom,
    RoomSessionStatus sessionStatus,
    signal.SessionCipher sessionCipher,
  }) =>
      RoomsState._(
        activeRoom: activeRoom ?? this.activeRoom,
        sessionStatus: sessionStatus ?? this.sessionStatus,
        sessionCipher: sessionCipher ?? this.sessionCipher,
      );

  @override
  List<Object> get props => [
        activeRoom,
        sessionStatus,
        sessionCipher,
      ];

  @override
  String toString() =>
      'RoomsState{activeRoom: $activeRoom, sessionStatus: $sessionStatus}';
}
