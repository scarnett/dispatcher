import 'package:dispatcher/graphql/service.dart';
import 'package:dispatcher/graphql/user.dart';
import 'package:dispatcher/models/models.dart';
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';

Logger _logger = Logger();

Future<List<UserConnection>> tryGetUserConnections(
  GraphQLClient client,
  User user, {
  int retryCount = 0,
  maxRetries = 10,
}) async {
  try {
    GraphQLService service = GraphQLService(client);
    final QueryResult result = await service.performQuery(
      fetchUserConnectionsQueryStr,
      variables: {'identifier': user.identifier},
    );

    if (result.hasException) {
      _logger.e({
        'graphql': result.exception.graphqlErrors.toString(),
        'client': result.exception.clientException.toString(),
      });
    } else {
      dynamic connections = result.data['user_connections'];
      if ((connections != null) && (connections.length > 0)) {
        return UserConnection.fromJsonList(connections);
      }

      // Retry get user connections
      if (retryCount < maxRetries) {
        return tryGetUserConnections(
          client,
          user,
          retryCount: (retryCount + 1),
        );
      }

      return [];
    }
  } catch (e) {
    _logger.e(e.toString());
  }

  return [];
}
