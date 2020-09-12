import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/connections/connections_viewmodel.dart';
import 'package:dispatcher/views/connections/widgets/connections_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class ConnectionsView extends StatefulWidget {
  ConnectionsView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends State<ConnectionsView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, ConnectionsViewModel>(
        converter: (store) => ConnectionsViewModel.fromStore(store),
        builder: (_, viewModel) => Scaffold(
          appBar: ConnectionsAppBar(
            height: 140,
          ),
        ),
      );
}
