import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class ConnectionsState extends Equatable {
  ConnectionsState();

  const ConnectionsState._();

  const ConnectionsState.initial() : this._();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'ConnectionsState{}';
}
