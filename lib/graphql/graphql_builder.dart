import 'package:dispatcher/graphql/graphql_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:redux/redux.dart';

class GraphQLBuilder<S> extends StatelessWidget {
  /// Builds a Widget using the [BuildContext] and your [Store].
  final ViewModelGraphQLBuilder<Store<S>> builder;

  /// Indicates whether or not the Widget should rebuild when the [Store] emits
  /// an `onChange` event.
  final bool rebuildOnChange;

  /// A function that will be run when the StoreConnector is initially created.
  /// It is run in the [State.initState] method.
  ///
  /// This can be useful for dispatching actions that fetch data for your Widget
  /// when it is first displayed.
  final OnInitCallback<S> onInit;

  /// A function that will be run when the StoreBuilder is removed from the
  /// Widget Tree.
  ///
  /// It is run in the [State.dispose] method.
  ///
  /// This can be useful for dispatching actions that remove stale data from
  /// your State tree.
  final OnDisposeCallback<S> onDispose;

  /// A function that will be run on State change, before the Widget is built.
  ///
  /// This can be useful for imperative calls to things like Navigator,
  /// TabController, etc
  final OnWillChangeCallback<Store<S>> onWillChange;

  /// A function that will be run on State change, after the Widget is built.
  ///
  /// This can be useful for running certain animations after the build is
  /// complete
  ///
  /// Note: Using a [BuildContext] inside this callback can cause problems if
  /// the callback performs navigation. For navigation purposes, please use
  /// [onWillChange].
  final OnDidChangeCallback<Store<S>> onDidChange;

  /// A function that will be run after the Widget is built the first time.
  ///
  /// This can be useful for starting certain animations, such as showing
  /// Snackbars, after the Widget is built the first time.
  final OnInitialBuildCallback<Store<S>> onInitialBuild;

  final QueryOptions query;
  final MutationOptions mutation;
  final OnMutationCompleted mutationCompleted;
  final PSubscription subscription;

  GraphQLBuilder({
    Key key,
    @required this.builder,
    this.onInit,
    this.onDispose,
    this.rebuildOnChange = true,
    this.onWillChange,
    this.onDidChange,
    this.onInitialBuild,
    this.query,
    this.mutation,
    this.mutationCompleted,
    this.subscription,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreBuilder<S>(
        rebuildOnChange: rebuildOnChange,
        onInit: onInit,
        onDispose: onDispose,
        onWillChange: onWillChange,
        onDidChange: onDidChange,
        onInitialBuild: onInitialBuild,
        builder: (
          BuildContext context,
          Store store,
        ) {
          GraphQLResponses response = GraphQLResponses();

          if (this.query != null) {
            return Query(
              options: this.query,
              builder: (
                QueryResult result, {
                VoidCallback refetch,
                FetchMore fetchMore,
              }) {
                response.query = result;

                if (this.subscription != null) {
                  return subscriptionRequest(context, store, response);
                }

                return mutationRequest(context, store, response);
              },
            );
          } else if (this.subscription != null) {
            return subscriptionRequest(context, store, response);
          } else if (this.mutation != null) {
            return mutationRequest(context, store, response);
          }

          return builder(context, store, response);
        },
      );

  /// Mutation request
  Widget mutationRequest(
    BuildContext context,
    Store<S> store,
    GraphQLResponses response,
  ) {
    if (this.mutation != null) {
      this.mutation.onCompleted = this.mutationCompleted;

      return Mutation(
        options: this.mutation,
        builder: (
          RunMutation runMutation,
          QueryResult query,
        ) {
          response.runMutation = runMutation;
          response.mutation = query;
          return builder(context, store, response);
        },
      );
    }

    return builder(context, store, response);
  }

  /// Subscription request
  Widget subscriptionRequest(
    BuildContext context,
    Store<S> store,
    GraphQLResponses response,
  ) =>
      Subscription(
        this.subscription.operationName,
        this.subscription.query,
        initial: this.subscription.initial,
        onCompleted: this.subscription.onCompleted,
        variables: this.subscription.variables,
        builder: ({
          bool loading,
          dynamic payload,
          dynamic error,
        }) {
          response.subcription.loading = loading;
          response.subcription.payload = payload;
          response.subcription.error = error;
          return mutationRequest(context, store, response);
        },
      );
}
