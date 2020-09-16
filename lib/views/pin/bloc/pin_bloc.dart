import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/services/graphql_service.dart';
import 'package:dispatcher/views/pin/bloc/pin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';

class PINBloc extends Bloc<PINEvent, PINState> {
  GraphQLService service;
  Logger logger = Logger();

  PINBloc(
    String token,
  ) : super(null) {
    service = GraphQLService(token);
  }

  PINState get initialState => PINState.loadInProgress();

  @override
  Stream<PINState> mapEventToState(
    PINEvent event,
  ) async* {
    if (event is FetchPINData) {
      yield* _mapFetchPINDataToStates(event);
    }
  }

  Stream<PINState> _mapFetchPINDataToStates(
    FetchPINData event,
  ) async* {
    final String query = event.query;
    final Map<String, dynamic> variables = event.variables ?? null;

    try {
      final QueryResult result =
          await service.performMutation(query, variables: variables);

      if (result.hasException) {
        logger.e(result.exception.graphqlErrors.toString());
        logger.e(result.exception.clientException.toString());
        yield PINState.loadFail();
      } else {
        yield PINState.loadSuccess(UserPIN.fromJson(result.data['users'][0]));
      }
    } catch (e) {
      logger.e(e.toString());
      yield PINState.loadFail();
    }
  }
}
