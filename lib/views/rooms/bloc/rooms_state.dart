part of 'rooms_bloc.dart';

@immutable
class RoomsState extends Equatable {
  final Room activeRoom;

  RoomsState({
    this.activeRoom,
  });

  const RoomsState._({
    this.activeRoom,
  });

  const RoomsState.initial() : this._();

  RoomsState copyWith({
    Room activeRoom,
  }) =>
      RoomsState._(
        activeRoom: activeRoom ?? this.activeRoom,
      );

  @override
  List<Object> get props => [activeRoom];

  @override
  String toString() => 'RoomsState{activeRoom: $activeRoom}';
}
