import 'package:graphql/client.dart';

class GraphQLService {
  GraphQLClient _client;

  GraphQLService(
    String token,
  ) {
    HttpLink link = HttpLink(
      uri: 'https://proper-molly-55.hasura.app/v1/graphql', // TODO! config
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
