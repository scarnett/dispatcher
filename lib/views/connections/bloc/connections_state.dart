part of 'connections_bloc.dart';

@immutable
class ConnectionsState extends Equatable {
  final UserConnection activeConnection;

  ConnectionsState({
    this.activeConnection,
  });

  const ConnectionsState._({
    this.activeConnection,
  });

  const ConnectionsState.initial() : this._();

  ConnectionsState copyWith({
    List<UserConnection> connections,
    UserConnection activeConnection,
  }) =>
      ConnectionsState._(
        activeConnection: activeConnection ?? this.activeConnection,
      );

  @override
  List<Object> get props => [activeConnection];

  @override
  String toString() => 'ConnectionsState{activeConnection: $activeConnection}';
}
