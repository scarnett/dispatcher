part of 'connections_bloc.dart';

@immutable
class ConnectionsState extends Equatable {
  ConnectionsState();

  const ConnectionsState._();

  const ConnectionsState.initial() : this._();

  ConnectionsState copyWith() => ConnectionsState._();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'ConnectionsState{}';
}
