import 'package:bloc/bloc.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/connections/connections_service.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
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
    if (event is FetchConnectionsData) {
      yield* _mapFetchConnectionsData(event);
    }
  }

  Stream<ConnectionsState> _mapFetchConnectionsData(
    FetchConnectionsData event,
  ) async* {
    if ((event.firebaseUser != null) && (state.connections == null)) {
      List<UserConnection> connections =
          await tryGetConnections(event.firebaseUser);

      if (connections != null) {
        yield state.copyWith(connections: connections);
      }
    }
  }
}
