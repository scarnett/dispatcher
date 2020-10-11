import 'package:dispatcher/graphql/service.dart';
import 'package:dispatcher/graphql/user.dart';
import 'package:dispatcher/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:graphql/client.dart';
import 'package:logger/logger.dart';

Logger _logger = Logger();

Future<List<UserConnection>> tryGetConnections(
  firebase.User firebaseUser,
) async {
  try {
    GraphQLService service = GraphQLService(await firebaseUser.getIdToken());
    final QueryResult result = await service.performMutation(
      fetchUserConnectionsQueryStr,
      variables: {
        'identifier': firebaseUser.uid,
      },
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

      return null;
    }
  } catch (e) {
    _logger.e(e.toString());
  }

  return null;
}
