import 'package:dispatcher/env_config.dart';
import 'package:graphql/client.dart';

class GraphQLService {
  GraphQLClient _client;

  GraphQLService(
    String token,
  ) {
    HttpLink link = HttpLink(
      uri: EnvConfig.DISPATCHER_GRAPHQL_URL,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _client = GraphQLClient(
      link: link,
      cache: InMemoryCache(),
    );
  }

  Future<QueryResult> performQuery(
    String query, {
    Map<String, dynamic> variables,
  }) async {
    QueryOptions options = QueryOptions(
      documentNode: gql(query),
      variables: variables,
    );

    final QueryResult result = await _client.query(options);
    return result;
  }

  Future<QueryResult> performMutation(
    String query, {
    Map<String, dynamic> variables,
  }) async {
    MutationOptions options = MutationOptions(
      documentNode: gql(query),
      variables: variables,
    );

    final QueryResult result = await _client.mutate(options);
    return result;
  }
}
