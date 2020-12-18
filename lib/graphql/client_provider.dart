import 'package:dispatcher/env_config.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

GraphQLClient clientFor({
  @required String uri,
  @required String token,
  String subscriptionUri,
  bool doSubscribe: false,
}) {
  Link link = HttpLink(
    uri: uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if ((subscriptionUri != null) && doSubscribe) {
    final WebSocketLink websocketLink = WebSocketLink(
      url: subscriptionUri,
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
        initPayload: () => {
          'headers': {
            'Authorization': 'Bearer $token',
          },
        },
      ),
    );

    link = link.concat(websocketLink);
  }

  return GraphQLClient(
    cache: OptimisticCache(
      dataIdFromObject: uuidFromObject,
    ),
    link: link,
  );
}

class ClientProvider extends StatelessWidget {
  final Widget child;
  final String uri;
  final String subscriptionUri;
  final bool doSubscribe;

  ClientProvider({
    @required this.child,
    this.uri: EnvConfig.DISPATCHER_GRAPHQL_ENDPOINT,
    this.subscriptionUri: EnvConfig.DISPATCHER_GRAPHQL_SUBSCRIPTION_ENDPOINT,
    this.doSubscribe: false,
  });

  @override
  Widget build(
    BuildContext context,
  ) =>
      FutureBuilder<String>(
        future: context.bloc<AuthBloc>().state.firebaseUser.getIdToken(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          String token;

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              // TODO! Loading...
              return Container();

            case ConnectionState.waiting:
              // TODO! Loading...
              return Container();

            default:
              // TODO! Show error
              if (snapshot.hasError) {
                return Container();
              }

              token = snapshot.data;
          }

          final GraphQLClient client = clientFor(
            token: token,
            uri: uri,
            subscriptionUri: subscriptionUri,
            doSubscribe: doSubscribe,
          );

          return GraphQLProvider(
            client: ValueNotifier<GraphQLClient>(client),
            child: Provider<GraphQLClient>(
              create: (_) => client,
              builder: (context, widget) => child,
            ),
          );
        },
      );
}
