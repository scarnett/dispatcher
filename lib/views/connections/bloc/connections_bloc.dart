import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'connections_event.dart';
part 'connections_state.dart';

class ConnectionsBloc extends Bloc<ConnectionsEvent, ConnectionsState> {
  ConnectionsBloc() : super(ConnectionsState.initial());

  ConnectionsState get initialState => ConnectionsState.initial();

  @override
  Stream<ConnectionsState> mapEventToState(
    ConnectionsEvent event,
  ) async* {}
}
