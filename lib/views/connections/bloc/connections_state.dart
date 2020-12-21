part of 'connections_bloc.dart';

@immutable
class ConnectionsState extends Equatable {
  final List<UserConnection> connections;

  const ConnectionsState._({
    this.connections,
  });

  const ConnectionsState.initial() : this._();

  ConnectionsState copyWith({
    List<UserConnection> connections,
  }) =>
      ConnectionsState._(
        connections: connections ?? this.connections,
      );

  @override
  List<Object> get props => [
        connections,
      ];

  @override
  String toString() => 'ConnectionsState{connections: ${connections?.length}}';
}
