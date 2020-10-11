import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/connections/bloc/bloc.dart';
import 'package:dispatcher/views/connections/widgets/connections_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectionsView extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ConnectionsView());

  const ConnectionsView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocProvider<ConnectionsBloc>(
        create: (BuildContext context) => ConnectionsBloc()
          ..add(
            FetchConnectionsData(context.bloc<AuthBloc>().state.firebaseUser),
          ),
        child: ConnectionsPageView(),
      );
}

class ConnectionsPageView extends StatefulWidget {
  ConnectionsPageView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectionsPageViewState();
}

class _ConnectionsPageViewState extends State<ConnectionsPageView>
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
      BlocBuilder<ConnectionsBloc, ConnectionsState>(
        builder: (
          BuildContext context,
          ConnectionsState state,
        ) =>
            Scaffold(
          appBar: ConnectionsAppBar(
            height: 140,
          ),
        ),
      );
}
