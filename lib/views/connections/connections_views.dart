import 'package:dispatcher/views/connections/widgets/connections_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      Scaffold(
        appBar: ConnectionsAppBar(
          height: 140,
        ),
      );
}
