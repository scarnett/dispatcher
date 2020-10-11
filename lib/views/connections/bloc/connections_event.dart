part of 'connections_bloc.dart';

abstract class ConnectionsEvent extends Equatable {
  const ConnectionsEvent();

  @override
  List<Object> get props => [];
}

class FetchConnectionsData extends ConnectionsEvent {
  final firebase.User firebaseUser;

  const FetchConnectionsData(
    this.firebaseUser,
  );

  @override
  List<Object> get props => [firebaseUser];
}
