import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/connect/connect_reducers.dart';

AppState appStateReducer(
  AppState state,
  dynamic action,
) =>
    AppState(
      connectState: connectReducer(state.connectState, action),
    );
