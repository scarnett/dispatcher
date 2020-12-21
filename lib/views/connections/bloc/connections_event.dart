part of 'connections_bloc.dart';

abstract class ConnectionsEvent extends Equatable {
  const ConnectionsEvent();

  @override
  List<Object> get props => [];
}

class FetchConnectionData extends ConnectionsEvent {
  final GraphQLClient client;
  final User user;

  const FetchConnectionData(
    this.client,
    this.user,
  );

  @override
  List<Object> get props => [client, user];
}
