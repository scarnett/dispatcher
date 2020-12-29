import 'package:dispatcher/graphql/client_provider.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/rooms/repository/rooms_repository.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/avatar/widgets/avatar_display.dart';
import 'package:dispatcher/views/rooms/bloc/bloc.dart';
import 'package:dispatcher/views/rooms/rooms_enums.dart';
import 'package:dispatcher/views/rooms/widgets/rooms_appbar.dart';
import 'package:dispatcher/widgets/none_found.dart';
import 'package:dispatcher/widgets/view_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger();

class RoomView extends StatelessWidget {
  final User user;

  static Route route(
    User user,
  ) =>
      MaterialPageRoute<void>(
        builder: (_) => RoomView(
          user: user,
        ),
      );

  const RoomView({
    Key key,
    this.user,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      ClientProvider(
        child: RepositoryProvider<RoomMessageRepository>(
          create: (context) => RoomMessageRepositoryFirestore()
            ..loadMessages(
              '-MP6Ne5IwbP3GvUEq8aw', // TODO!
              context.bloc<AuthBloc>().state.user.identifier,
            ),
          child: BlocProvider<RoomsBloc>(
            create: (BuildContext context) => RoomsBloc(
              roomMessageRepository: RepositoryProvider.of(context),
            ),
            child: RoomPageView(user: user),
          ),
        ),
      );
}

class RoomPageView extends StatefulWidget {
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

  // The scroll controller for the ListView
  ScrollController _messageListViewController;

  TextEditingController _messageTextController;

  @override
  void initState() {
    // Fetch the room data
    context.bloc<RoomsBloc>()
      ..add(
        FetchRoomData(
          Provider.of<GraphQLClient>(context, listen: false),
          context.bloc<AuthBloc>().state.user,
          widget.user,
        ),
      );

    // Setup the ListView controller
    _messageListViewController = ScrollController();

    // Setup the Message text controller
    _messageTextController = TextEditingController();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  /// Handles the android back button
  Future<bool> _willPopCallback() {
    context.bloc<RoomsBloc>().add(ClearRoomData());
    return Future.value(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageListViewController?.dispose();
    _messageTextController?.dispose();
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
            WillPopScope(
          onWillPop: () => _willPopCallback(),
          child: Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: true,
            appBar: RoomAppBar(
              height: 60.0,
              title: widget.user.name,
              onBackButtonPressed: () =>
                  context.bloc<RoomsBloc>().add(ClearRoomData()),
            ),
            body: _buildContent(state),
          ),
        ),
      );

  /// Builds the content
  Widget _buildContent(
    RoomsState state,
  ) {
    switch (context.bloc<RoomsBloc>().state.sessionStatus) {
      case RoomSessionStatus.CANT_CREATE:
        return _buildSessionError();

      case RoomSessionStatus.CREATED:
        return _buildMessageContent(state);

      case RoomSessionStatus.NONE:
      case RoomSessionStatus.CREATING:
      default:
        return ViewMessage(
          message: AppLocalizations.of(context).sessionEncryption,
          showSpinner: false,
          icon: AvatarDisplay(user: widget.user),
        );
    }
  }

  /// Builds the message content
  Widget _buildMessageContent(
    RoomsState state,
  ) =>
      Column(
        children: <Widget>[
          _buildMessageList(state),
          _buildMessageField(),
        ],
      );

  /// Builds the message list
  Widget _buildMessageList(
    RoomsState state,
  ) =>
      StreamBuilder<List<RoomMessage>>(
        stream: context.bloc<RoomsBloc>().messages,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<RoomMessage>> snapshot,
        ) {
          if (snapshot.hasError) {
            // TODO! Handle error
            return NoneFound(
              message: AppLocalizations.of(context).messagesNone,
            );
          }

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              // TODO! Handle
              return Container();

            case ConnectionState.waiting:
              // TODO! Handle
              return Container();

            case ConnectionState.active:
            case ConnectionState.done:
              // TODO! Handle
              return Expanded(
                child: ListView.builder(
                  controller: _messageListViewController,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.length ?? 0,
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    try {
                      RoomMessage message = snapshot.data?.elementAt(index);
                      String result = message.message.toString();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                        child: Text(result),
                      );
                    } catch (e) {
                      _logger.e(e);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                        child: Text('message'), // TODO! decrypt error
                      );
                    }
                  },
                ),
              );

            default:
              // TODO! Handle
              return Container();
          }
        },
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
                            controller: _messageTextController,
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

  Widget _buildSessionError() => ViewMessage(
        message: AppLocalizations.of(context).sessionEncryptionError,
        messageColor: AppTheme.error,
        showSpinner: false,
        iconData: Icons.error,
        iconColor: AppTheme.error,
        showButton: true,
        buttonText: AppLocalizations.of(context).goBack,
        buttonOnPressed: () => Navigator.pop(context),
      );

  /// Handles a 'done' tap
  void _tapDone(
    String value,
  ) {
    context.bloc<RoomsBloc>().add(
          SendMessage(
            context.bloc<AuthBloc>().state.user,
            widget.user,
            value,
          ),
        );

    _messageTextController.clear();
  }
}
