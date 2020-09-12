import 'package:dispatcher/device/device_viewmodel.dart';
import 'package:dispatcher/extensions/string_extensions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/pin/pin_config.dart';
import 'package:dispatcher/views/pin/pin_utils.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/pin_code.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Displays the migrate from view
class MigrateFromDeviceView extends StatefulWidget {
  MigrateFromDeviceView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MigrateFromDeviceViewState();
}

class _MigrateFromDeviceViewState extends State<MigrateFromDeviceView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _authticated = false;
  String _pinCode;
  SharedPreferences _prefs;

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, DeviceViewModel>(
        converter: (store) => DeviceViewModel.fromStore(store),
        onInit: (store) async => _prefs = await SharedPreferences.getInstance(),
        builder: (_, viewModel) => Scaffold(
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
                  _buildBody(viewModel),
                ],
              ),
            ),
          ),
        ),
      );

  /// Builds the migrate from body
  Widget _buildBody(
    DeviceViewModel viewModel,
  ) {
    if ((viewModel.device.user.pin == null) ||
        (viewModel.device.user.pin.pinCode == null)) {
      return _buildPINCodeMessage(viewModel);
    } else if (!_authticated) {
      return _buildPINCodeForm(viewModel);
    }

    return _buildMigrateFromQRCode(viewModel);
  }

  /// Builds the 'pin code' message
  Widget _buildPINCodeMessage(
    DeviceViewModel viewModel,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context).setPinCodeMigrateFrom,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: FormButton(
              text: AppLocalizations.of(context).setPINCode,
              onPressed: () => _tapValidatePIN(viewModel),
            ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => _tapCancel(),
            textColor: AppTheme.accent,
          ),
        ],
      );

  /// Builds the 'pin code' form
  Widget _buildPINCodeForm(
    DeviceViewModel viewModel,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context).enterPin,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Container(
            child: PinCodeTextField(
              key: Key('pinCodeKey'),
              keyboardType: TextInputType.number,
              maxLength: PINConfig.PIN_CODE_LENGTH,
              spacerIndex: 0,
              onTextChanged: (text) => setState(() => _pinCode =
                  (text.length == PINConfig.PIN_CODE_LENGTH) ? text : null),
              onDone: (text) => setState(() => _pinCode = text),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: FormButton(
              text: AppLocalizations.of(context).verifyPINCode,
              onPressed: (!_pinCode.isNullEmptyOrWhitespace &&
                      (_pinCode.length == PINConfig.PIN_CODE_LENGTH))
                  ? () => _tapValidatePIN(viewModel)
                  : null,
            ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => _tapCancel(),
            textColor: AppTheme.accent,
          ),
        ],
      );

  /// Builds the migrate from qr code
  Widget _buildMigrateFromQRCode(
    DeviceViewModel viewModel,
  ) =>
      Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context)
                .migrateFromText(AppLocalizations.appTitle),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: QrImage(
              data: viewModel.device.id,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => Navigator.pop(context),
            textColor: AppTheme.accent,
          ),
        ],
      );

  /// Handles the 'validate pin code' tap
  void _tapValidatePIN(
    DeviceViewModel viewModel,
  ) {
    if (isValidPIN(_prefs, viewModel.device.user.pin, _pinCode)) {
      setState(() => _authticated = true);
    } else {
      _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
        text: AppLocalizations.of(context).invalidPINCode,
        type: MessageType.ERROR,
      )));
    }
  }

  /// Handles the 'cancel' tap
  void _tapCancel() => Navigator.pop(context);
}
