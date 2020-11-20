import 'dart:convert';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/avatar/widgets/avatar_display.dart';
import 'package:dispatcher/views/connections/bloc/bloc.dart';
import 'package:dispatcher/views/rooms/bloc/bloc.dart';
import 'package:dispatcher/views/rooms/widgets/room_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart' as signal;

class RoomView extends StatelessWidget {
  // final List<User> users;
  final User user;

  static Route route(
    User user,
  ) =>
      MaterialPageRoute<void>(
        builder: (_) => RoomView(user: user),
      );

  const RoomView({
    Key key,
    this.user,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocProvider<RoomsBloc>(
        create: (BuildContext context) => RoomsBloc()
          ..add(
            FetchRoomData([
              context.bloc<AuthBloc>().state.user.identifier,
              user.identifier,
            ]),
          ),
        child: RoomPageView(user: user),
      );
}

class RoomPageView extends StatefulWidget {
  // final List<User> users;
  final User user;

  RoomPageView({
    Key key,
    this.user,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoomPageViewState();
}

class _RoomPageViewState extends State<RoomPageView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // The signal session cipher
  signal.SessionCipher _sessionCipher;

  @override
  void initState() {
    // TODO! FIX
    // _sessionCipher = buildSessionCipher(widget.user, widget.connection);

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocBuilder<RoomsBloc, RoomsState>(
        builder: (
          BuildContext context,
          RoomsState state,
        ) =>
            Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: true,
          appBar: RoomAppBar(
            height: 60.0,
            title: widget.user.name,
          ),
          body: _buildContent(),
        ),
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
  // TODO!
  void _tapDone(
    String value,
  ) {
    signal.CiphertextMessage cipherText =
        _sessionCipher.encrypt(utf8.encode(value));

    print(String.fromCharCodes(cipherText.serialize()));

    signal.PreKeySignalMessage msgIn =
        signal.PreKeySignalMessage(cipherText.serialize());

    print(msgIn.getType());
  }
}
