import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/text_utils.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/avatar/widgets/avatar_display.dart';
import 'package:dispatcher/views/connections/bloc/bloc.dart';
import 'package:dispatcher/views/connections/widgets/connections_appbar.dart';
import 'package:dispatcher/views/room/room_views.dart';
import 'package:dispatcher/widgets/none_found.dart';
import 'package:dispatcher/widgets/spinner.dart';
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
        create: (BuildContext context) => ConnectionsBloc(),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // The scroll controller for the ListView
  ScrollController _connectionsListViewController;

  @override
  void initState() {
    // Setup the ListView controller
    _connectionsListViewController = ScrollController();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionsListViewController?.dispose();
    super.dispose();
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
          key: _scaffoldKey,
          resizeToAvoidBottomInset: true,
          appBar: ConnectionsAppBar(height: 80.0),
          body: _buildContent(state),
        ),
      );

  /// Builds the content
  Widget _buildContent(
    ConnectionsState state,
  ) {
    if ((state == null) ||
        (context.bloc<AuthBloc>().state.user.connections == null)) {
      return Spinner(
        message: AppLocalizations.of(context).connectionsLoading,
        centered: false,
      );
    }

    return Column(
      children: <Widget>[
        _buildConnectionsList(state),
      ],
    );
  }

  /// Builds a list of contact widgets.
  Widget _buildConnectionsList(
    ConnectionsState state,
  ) {
    List<UserConnection> connections =
        context.bloc<AuthBloc>().state.user.connections;

    if ((connections == null) || (connections.length == 0)) {
      return NoneFound(
        message: AppLocalizations.of(context).connectionsNone,
      );
    }

    return Flexible(
      child: ListView.builder(
        controller: _connectionsListViewController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: connections?.length ?? 0,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          UserConnection connection = connections?.elementAt(index);

          return InkWell(
            onTap: () => _tapConnection(
              [
                context.bloc<AuthBloc>().state.user,
                connection.connectionUser,
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: AvatarDisplay(
                      user: connection.connectionUser,
                      avatarRadius: 28.0,
                      progressStrokeWidth: 2.0,
                    ),
                  ),
                  _buildConnection(connection),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a connection widget.
  Widget _buildConnection(
    UserConnection connection,
  ) {
    List<Widget> children = <Widget>[]
      ..add(
        Text(
          removeEmojis(connection.connectionUser.name),
          style: Theme.of(context).textTheme.headline6,
        ),
      )
      ..add(
        Text(
          connection.connectionUser.email,
          style: Theme.of(context).textTheme.subtitle2,
        ),
      );

    return Container(
      child: Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  /// Handles the 'connection' tap
  void _tapConnection(
    List<User> users,
  ) =>
      Navigator.push(context, RoomView.route(users));
}
