import 'package:graphql/client.dart';

class GraphQLService {
  GraphQLClient _client;

  GraphQLService(
    GraphQLClient client,
  ) {
    _client = client;
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

  Stream<FetchResult> subscribe(
    String query, {
    Map<String, dynamic> variables,
  }) {
    Operation operation = Operation(
      documentNode: gql(query),
      variables: variables,
    );

    return _client.subscribe(operation);
  }
}
