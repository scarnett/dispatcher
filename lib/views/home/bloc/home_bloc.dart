import 'package:dispatcher/services/graphql_service.dart';
import 'package:dispatcher/user/user_model.dart';
import 'package:dispatcher/views/home/bloc/home_events.dart';
import 'package:dispatcher/views/home/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  GraphQLService service;
  Logger logger = Logger();

  HomeBloc(
    String token,
  ) : super(null) {
    service = GraphQLService(token);
  }

  HomeState get initialState => HomeState.loadInProgress();

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is FetchHomeData) {
      yield* _mapFetchHomeDataToStates(event);
    } else if (event is SelectedTabIndex) {
      yield _mapSelectedTabIndexToStates(event);
    }
  }

  Stream<HomeState> _mapFetchHomeDataToStates(
    FetchHomeData event,
  ) async* {
    final String query = event.query;
    final Map<String, dynamic> variables = event.variables ?? null;

    try {
      final QueryResult result =
          await service.performMutation(query, variables: variables);

      if (result.hasException) {
        logger.e(result.exception.graphqlErrors.toString());
        logger.e(result.exception.clientException.toString());
        yield HomeState.loadFail();
      } else {
        yield HomeState.loadSuccess(User.fromJson(result.data['users'][0]));
      }
    } catch (e) {
      logger.e(e.toString());
      yield HomeState.loadFail();
    }
  }

  HomeState _mapSelectedTabIndexToStates(
    SelectedTabIndex event,
  ) =>
      state.copyWith(
        selectedTabIndex: event.index,
      );
}
