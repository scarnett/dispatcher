import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:redux/redux.dart';

// Combine Between StoreProvider Of Redux And GraphqlProvider Of Graphql
// @see https://github.com/zino-app/graphql-flutter/issues/172
class GraphXProvider<S> extends StatefulWidget {
  const GraphXProvider({
    Key key,
    this.client,
    this.child,
    this.store,
  }) : super(key: key);

  final ValueNotifier<GraphQLClient> client;
  final Widget child;
  final Store<S> store;

  @override
  State<StatefulWidget> createState() => _GraphXProviderState<S>();
}

class _GraphXProviderState<S> extends State<GraphXProvider> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreProvider<S>(
        store: widget.store,
        child: GraphQLProvider(
          client: widget.client,
          child: widget.child,
        ),
      );
}
