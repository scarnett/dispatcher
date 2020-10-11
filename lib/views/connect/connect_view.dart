import 'package:dispatcher/extensions/extensions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/avatar/widgets/avatar_display.dart';
import 'package:dispatcher/views/connect/bloc/connect_bloc.dart';
import 'package:dispatcher/views/connect/connect_enums.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/pin_code.dart';
import 'package:dispatcher/widgets/progress.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectView extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ConnectView());

  const ConnectView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocProvider<ConnectBloc>(
        create: (BuildContext context) => ConnectBloc(),
        child: ConnectPageView(),
      );
}

class ConnectPageView extends StatefulWidget {
  ConnectPageView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectPageViewState();
}

class _ConnectPageViewState extends State<ConnectPageView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String inviteCode;

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocListener<ConnectBloc, ConnectState>(
        listener: (
          BuildContext context,
          ConnectState state,
        ) {
          switch (state.status) {
            case ConnectStatus.CONNECTION_FOUND:
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text: AppLocalizations.of(context).connectionFoundText,
                type: MessageType.SUCCESS,
              )));

              break;

            case ConnectStatus.CONNECTION_NOT_FOUND:
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text: AppLocalizations.of(context).connectionNotFoundText,
                type: MessageType.ERROR,
              )));

              break;

            case ConnectStatus.CONNECTED:
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text: AppLocalizations.of(context).connectSuccess,
                type: MessageType.SUCCESS,
              )));

              break;

            case ConnectStatus.ALREADY_CONNECTED:
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text: AppLocalizations.of(context)
                    .alreadyConnectedText(state.lookupUser),
                type: MessageType.SUCCESS,
              )));

              break;

            default:
              break;
          }
        },
        child: BlocBuilder<ConnectBloc, ConnectState>(
          builder: (
            BuildContext context,
            ConnectState state,
          ) =>
              WillPopScope(
            onWillPop: () => _willPopCallback(),
            child: Scaffold(
              key: _scaffoldKey,
              appBar: SimpleAppBar(
                showLeading: true,
                leadingIcon: (state.lookupUser == null) ? null : Icons.close,
                height: 100.0,
              ),
              body: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      _createContent(state),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    super.dispose();
  }

  /// Handles the android back button
  Future<bool> _willPopCallback() async {
    context.bloc<ConnectBloc>().add(ClearConnect());
    return Future.value(true);
  }

  Widget _createContent(
    ConnectState state,
  ) {
    if (state.status == ConnectStatus.CANT_CONNECT) {
      return _buildCantConnect(state);
    } else if ((state.lookupUser == null) &&
        (state.status != ConnectStatus.ALREADY_CONNECTED)) {
      return _buildInviteCodeForm(state);
    } else if (state.status == ConnectStatus.ALREADY_CONNECTED) {
      return _buildAlreadyConnected(state);
    } else if ((state.lookupUser != null) &&
        (state.status != ConnectStatus.CONNECTED)) {
      return _buildConfirmForm(state);
    }

    return _buildSuccessContent(state);
  }

  Widget _buildInviteCodeForm(
    ConnectState state,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context).enterInviteCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Container(
            child: PinCodeTextField(
              onTextChanged: (text) => setState(() => inviteCode =
                  (text.length == INVITE_CODE_LENGTH) ? text : null),
              onDone: (text) => setState(() => inviteCode = text),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context).getInviteCodeText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          (state.eventType == ConnectEventType.LOOKING_UP)
              ? Progress()
              : FormButton(
                  text: AppLocalizations.of(context).lookup,
                  onPressed: (!inviteCode.isNullEmptyOrWhitespace &&
                          (inviteCode.length == INVITE_CODE_LENGTH))
                      ? () => context.bloc<ConnectBloc>().add(
                            LookupUser(
                              context.bloc<AuthBloc>().state.firebaseUser,
                              inviteCode,
                            ),
                          )
                      : null,
                ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => Navigator.pop(context),
            textColor: AppTheme.accent,
            textButton: true,
          ),
        ],
      );

  Widget _buildConfirmForm(
    ConnectState state,
  ) =>
      Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 20.0,
              ),
              child: Text(
                AppLocalizations.of(context).wouldYouConnect,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: AvatarDisplay(
                user: state.lookupUser,
                avatarRadius: 48.0,
              ),
            ),
            Text(
              state.lookupUser.name,
              style: Theme.of(context).textTheme.headline5,
            ),
            state.lookupUser.email.isNullEmptyOrWhitespace
                ? Container()
                : Text(
                    state.lookupUser.email,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: (state.eventType == ConnectEventType.CONNECTING)
                  ? Progress()
                  : FormButton(
                      text: AppLocalizations.of(context).connect,
                      onPressed: () => context.bloc<ConnectBloc>().add(
                            ConnectUser(
                              context.bloc<AuthBloc>().state.firebaseUser.uid,
                              state.lookupUser.identifier,
                            ),
                          ),
                    ),
            ),
            FormButton(
              color: Colors.transparent,
              text: AppLocalizations.of(context).cancel,
              onPressed: () => _tapOK(),
              textColor: AppTheme.accent,
              textButton: true,
            ),
          ],
        ),
      );

  Widget _buildSuccessContent(
    ConnectState state,
  ) =>
      Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 20.0,
              ),
              child: Text(
                AppLocalizations.of(context)
                    .connectSuccessText(state.lookupUser),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: AvatarDisplay(
                user: state.lookupUser,
                avatarRadius: 48.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: FormButton(
                text: AppLocalizations.of(context).ok,
                onPressed: () => _tapOK(),
              ),
            ),
          ],
        ),
      );

  Widget _buildAlreadyConnected(
    ConnectState state,
  ) =>
      Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 20.0,
              ),
              child: Text(
                AppLocalizations.of(context)
                    .alreadyConnectedText(state.lookupUser),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: AvatarDisplay(
                user: state.lookupUser,
                avatarRadius: 48.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: FormButton(
                text: AppLocalizations.of(context).ok,
                onPressed: () => _tapOK(),
              ),
            ),
          ],
        ),
      );

  Widget _buildCantConnect(
    ConnectState state,
  ) =>
      Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 20.0,
              ),
              child: Text(
                AppLocalizations.of(context).cantConnectText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: FormButton(
                text: AppLocalizations.of(context).ok,
                onPressed: () => _tapOK(
                  clear: true,
                  redirect: false,
                ),
              ),
            ),
          ],
        ),
      );

  void _tapOK({
    bool clear: false,
    bool redirect: true,
  }) {
    if (clear) {
      context.bloc<ConnectBloc>().add(ClearConnect());
    }

    if (redirect) {
      Navigator.pop(context);
    }
  }
}
