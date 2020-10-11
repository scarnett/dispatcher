import 'package:dispatcher/views/connections/bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ConnectionsBloc extends HydratedBloc<ConnectionsEvent, ConnectionsState> {
  ConnectionsBloc() : super(ConnectionsState.initial());

  ConnectionsState get initialState => ConnectionsState.initial();

  @override
  Stream<ConnectionsState> mapEventToState(
    ConnectionsEvent event,
  ) async* {}

  @override
  ConnectionsState fromJson(
    Map<String, dynamic> json,
  ) =>
      throw UnimplementedError();

  @override
  Map<String, dynamic> toJson(
    ConnectionsState state,
  ) =>
      throw UnimplementedError();
}
