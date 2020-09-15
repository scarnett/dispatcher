import 'package:dispatcher/device/widgets/device_avatar.dart';
import 'package:dispatcher/extensions/string_extensions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/connect/connect_viewmodel.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/pin_code.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class ConnectView extends StatefulWidget {
  ConnectView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectViewState();
}

class _ConnectViewState extends State<ConnectView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String inviteCode;

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, ConnectViewModel>(
        converter: (store) => ConnectViewModel.fromStore(store),
        builder: (_, viewModel) => WillPopScope(
          onWillPop: () => _willPopCallback(viewModel),
          child: Scaffold(
            key: _scaffoldKey,
            appBar: SimpleAppBar(
              height: 100.0,
            ),
            body: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    _createContent(viewModel),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _scaffoldKey.currentState.dispose();
    super.dispose();
  }

  Future<bool> _willPopCallback(
    ConnectViewModel viewModel,
  ) async {
    viewModel.cancelConnectDevice();
    return Future.value(true);
  }

  // TODO! update 'connections' of other device
  Widget _createContent(
    ConnectViewModel viewModel,
  ) {
    if (viewModel.cantConnect) {
      return _buildCantConnect(viewModel);
    } else if ((viewModel.lookupResult) == null &&
        !viewModel.alreadyConnected) {
      return _buildInviteCodeForm(viewModel);
    } else if (viewModel.alreadyConnected) {
      return _buildAlreadyConnected(viewModel);
    } else if ((viewModel.lookupResult != null) && !viewModel.connected) {
      return _buildConfirmForm(viewModel);
    }

    return _buildSuccessContent(viewModel);
  }

  Widget _buildInviteCodeForm(
    ConnectViewModel viewModel,
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
          FormButton(
            color: AppTheme.primary,
            text: AppLocalizations.of(context).lookup,
            onPressed: (!inviteCode.isNullEmptyOrWhitespace &&
                    (inviteCode.length == INVITE_CODE_LENGTH))
                ? () => viewModel.lookupDeviceByInviteCode(
                    inviteCode, context, _scaffoldKey)
                : null,
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => Navigator.pop(context),
            textColor: AppTheme.accent,
          ),
        ],
      );

  Widget _buildConfirmForm(
    ConnectViewModel viewModel,
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
              child: DeviceAvatar(
                user: viewModel.lookupResult.user,
                avatarRadius: 48.0,
              ),
            ),
            Text(
              viewModel.lookupResult.user.name,
              style: Theme.of(context).textTheme.headline5,
            ),
            viewModel.lookupResult.user.email.isNullEmptyOrWhitespace
                ? Container()
                : Text(
                    viewModel.lookupResult.user.email,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: FormButton(
                color: AppTheme.primary,
                text: AppLocalizations.of(context).connect,
                onPressed: () => viewModel.connectDevice(
                  viewModel.deviceId,
                  viewModel.lookupResult.id,
                  context,
                  _scaffoldKey,
                ),
              ),
            ),
            FormButton(
              color: Colors.transparent,
              text: AppLocalizations.of(context).cancel,
              onPressed: () => viewModel.cancelConnectDevice(),
              textColor: AppTheme.accent,
            ),
          ],
        ),
      );

  Widget _buildSuccessContent(
    ConnectViewModel viewModel,
  ) =>
      Container(
        padding: const EdgeInsets.only(top: 100.0),
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
                    .connectSuccessText(viewModel.lookupResult.user),
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
              child: DeviceAvatar(
                user: viewModel.lookupResult.user,
                avatarRadius: 48.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: FormButton(
                text: AppLocalizations.of(context).ok,
                onPressed: () => _tapOK(viewModel),
              ),
            ),
          ],
        ),
      );

  Widget _buildAlreadyConnected(
    ConnectViewModel viewModel,
  ) =>
      Container(
        padding: const EdgeInsets.only(top: 100.0),
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
                    .alreadyConnectedText(viewModel.lookupResult.user),
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
              child: DeviceAvatar(
                user: viewModel.lookupResult.user,
                avatarRadius: 48.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: FormButton(
                text: AppLocalizations.of(context).ok,
                onPressed: () => _tapOK(viewModel),
              ),
            ),
          ],
        ),
      );

  Widget _buildCantConnect(
    ConnectViewModel viewModel,
  ) =>
      Container(
        padding: const EdgeInsets.only(top: 100.0),
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
                  viewModel,
                  redirect: false,
                ),
              ),
            ),
          ],
        ),
      );

  void _tapOK(
    ConnectViewModel viewModel, {
    bool redirect: true,
  }) {
    viewModel.cancelConnectDevice();

    if (redirect) {
      Navigator.pop(context);
    }
  }
}
