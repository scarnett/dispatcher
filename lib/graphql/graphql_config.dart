import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String APP_GRAPHQL_URL = 'proper-molly-55.hasura.app/v1/graphql'; // TODO!

class HasuraConfig {
  static String _token;

  static final HttpLink httpLink = HttpLink(
    uri: 'https://$APP_GRAPHQL_URL',
  );

  static final AuthLink authLink = AuthLink(
    getToken: () => _token,
  );

  static final WebSocketLink websocketLink = WebSocketLink(
    url: 'wss://$APP_GRAPHQL_URL',
    config: SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: const Duration(seconds: 30),
      initPayload: () => {
        'headers': {
          'Authorization': _token,
        },
      },
    ),
  );

  static final Link link = authLink.concat(httpLink).concat(websocketLink);

  static ValueNotifier<GraphQLClient> initailizeClient(
    String token,
  ) {
    _token = token;

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
        link: link,
      ),
    );

    return client;
  }
}
