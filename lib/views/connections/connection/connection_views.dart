import 'dart:convert';
import 'dart:typed_data';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/avatar/widgets/avatar_display.dart';
import 'package:dispatcher/views/connections/bloc/bloc.dart';
import 'package:dispatcher/views/connections/connection/widgets/connection_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart' as signal;

class ConnectionView extends StatelessWidget {
  final UserConnection connection;

  static Route route(
    UserConnection connection,
  ) =>
      MaterialPageRoute<void>(
          builder: (_) => ConnectionView(connection: connection));

  const ConnectionView({
    Key key,
    this.connection,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocProvider<ConnectionsBloc>(
        create: (BuildContext context) => ConnectionsBloc(),
        child: ConnectionPageView(connection: connection),
      );
}

class ConnectionPageView extends StatefulWidget {
  final UserConnection connection;

  ConnectionPageView({
    Key key,
    this.connection,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectionPageViewState();
}

class _ConnectionPageViewState extends State<ConnectionPageView>
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
      Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: ConnectionAppBar(
          height: 60.0,
          title: widget.connection.connectUser.name,
        ),
        body: _buildContent(),
      );

  /// Builds the content
  Widget _buildContent() => Column(
        children: <Widget>[
          _buildMessageList(),
          _buildMessageField(),
        ],
      );

  /// Builds the message list
  Widget _buildMessageList() => Expanded(
        child: SizedBox(
          width: double.infinity,
          child: Container(),
        ),
      );

  /// Builds the message field
  Widget _buildMessageField() => SizedBox(
        width: double.infinity,
        child: Container(
          margin: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.grey,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        child: AvatarDisplay(
                          user: context.bloc<AuthBloc>().state.user,
                          avatarRadius: 15.0,
                          progressStrokeWidth: 2.0,
                          showBorder: false,
                        ),
                      ),
                      Expanded(
                        child: Theme(
                          data: ThemeData(buttonColor: AppTheme.primary),
                          child: TextFormField(
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(context).saySomething,
                              hintStyle: TextStyle(color: AppTheme.accent),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            onFieldSubmitted: (String value) => _tapDone(value),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  /// Handles a 'done' tap
  void _tapDone(
    String value,
  ) {
    print('1111');

    signal.SenderKeyName senderKeyName =
        signal.SenderKeyName('', signal.SignalProtocolAddress('sender', 1));

    print('2222');

    signal.InMemorySenderKeyStore senderKeyStore =
        signal.InMemorySenderKeyStore();

    print(senderKeyStore.loadSenderKey(senderKeyName).serialize());
    signal.GroupCipher groupSession =
        signal.GroupCipher(senderKeyStore, senderKeyName);

    print('4444');
    Uint8List message = groupSession.encrypt(utf8.encode('Hello Mixin'));
    print('5555');
    print(message);
  }
}
