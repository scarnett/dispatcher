import 'package:bloc/bloc.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/connections/connections_service.dart';
import 'package:equatable/equatable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';

part 'connections_event.dart';
part 'connections_state.dart';

class ConnectionsBloc extends Bloc<ConnectionsEvent, ConnectionsState> {
  ConnectionsBloc() : super(ConnectionsState.initial());

  ConnectionsState get initialState => ConnectionsState.initial();

  @override
  Stream<ConnectionsState> mapEventToState(
    ConnectionsEvent event,
  ) async* {
    if (event is FetchConnectionData) {
      yield await _mapFetchConnectionDataToStates(event);
    }
  }

  Future<ConnectionsState> _mapFetchConnectionDataToStates(
    FetchConnectionData event,
  ) async {
    List<UserConnection> connections =
        await tryGetUserConnections(event.client, event.user);

    return state.copyWith(
      connections: connections,
    );
  }
}
