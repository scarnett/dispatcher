part of 'connections_bloc.dart';

@immutable
class ConnectionsState extends Equatable {
  final List<UserConnection> connections;
  final UserConnection activeConnection;

  ConnectionsState({
    this.connections,
    this.activeConnection,
  });

  const ConnectionsState._({
    this.connections,
    this.activeConnection,
  });

  const ConnectionsState.initial() : this._();

  ConnectionsState copyWith({
    List<UserConnection> connections,
    UserConnection activeConnection,
  }) =>
      ConnectionsState._(
        connections: connections ?? this.connections,
        activeConnection: activeConnection ?? this.activeConnection,
      );

  @override
  List<Object> get props => [connections, activeConnection];

  @override
  String toString() =>
      'ConnectionsState{connections: ${connections?.length}, activeConnection: $activeConnection}';
}
