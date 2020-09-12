import 'package:redux/redux.dart';
import 'package:dispatcher/state.dart';

class ConnectionsViewModel {
  ConnectionsViewModel();

  static ConnectionsViewModel fromStore(
    Store<AppState> store,
  ) =>
      ConnectionsViewModel();
}
