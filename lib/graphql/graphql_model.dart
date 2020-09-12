// Params subsciption
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class PSubscription {
  final String operationName;
  final String query;
  final dynamic variables;
  final OnSubscriptionCompleted onCompleted;
  final dynamic initial;

  PSubscription({
    this.operationName,
    this.query,
    this.variables,
    this.initial,
    this.onCompleted,
  });
}

// GraphQL subcription
class GraphQLResponsesSubscription {
  bool loading;
  dynamic payload;
  dynamic error;
}

// Graphql Responses
class GraphQLResponses {
  // Query response
  QueryResult query;

  // Mutation response
  RunMutation runMutation;
  QueryResult mutation;

  // Subscription response
  GraphQLResponsesSubscription subcription;
}

/// Build a Widget using the [BuildContext] and [ViewModel]. The [ViewModel] is
/// derived from the [Store] using a [StoreConverter].
typedef ViewModelGraphQLBuilder<ViewModel> = Widget Function(
  BuildContext context,
  ViewModel viewModel,
  GraphQLResponses response,
);
