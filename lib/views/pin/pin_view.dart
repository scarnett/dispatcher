import 'dart:typed_data';
import 'package:dispatcher/device/device_viewmodel.dart';
import 'package:dispatcher/extensions/string_extensions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/rsa/rsa_key_helper.dart';
import 'package:dispatcher/rsa/rsa_keys.dart';
import 'package:dispatcher/rsa/rsa_utils.dart';
import 'package:dispatcher/sms/sms_model.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/date_utils.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/pin/pin_config.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/pin_code.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pointycastle/export.dart' as rsa;
import 'package:shared_preferences/shared_preferences.dart';

// Displays the 'PIN' view
class PINView extends StatefulWidget {
  PINView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PINViewState();
}

class _PINViewState extends State<PINView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _phoneNumberFormKey = GlobalKey<FormState>();
  TextEditingController _phoneController = TextEditingController();

  bool _verified = false;
  bool _saved = false;
  String _verificationCode;
  String _pinCode;
  SharedPreferences _prefs;

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, DeviceViewModel>(
        converter: (store) => DeviceViewModel.fromStore(store),
        onInit: (store) async => _prefs = await SharedPreferences.getInstance(),
        builder: (_, viewModel) => FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (
            BuildContext context,
            AsyncSnapshot<SharedPreferences> snapshot,
          ) {
            if (snapshot.hasData) {
              return Scaffold(
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
              );
            }

            return Spinner();
          },
        ),
      );

  @override
  void dispose() {
    _phoneController.dispose();
    _verified = false;
    _saved = false;
    super.dispose();
  }

  /// Builds the pin body
  Widget _buildBody(
    DeviceViewModel viewModel,
  ) {
    DateTime now = getNow();

    if (_verified) {
      return _buildPINCodeForm(viewModel);
    } else if (_saved) {
      return _buildPINCodeConfirmation(viewModel);
    } else if (viewModel
        .device.user.phone.phoneNumber.isNullEmptyOrWhitespace) {
      return _buildPhoneNumberMessage(viewModel);
    } else if ((viewModel.device.user.pin == null) ||
        viewModel.device.user.pin.verificationCode.isNullEmptyOrWhitespace ||
        now.isAfter(viewModel.device.user.pin.verificationExpireDate)) {
      if (!viewModel.device.user.pin.verificationCode.isNullEmptyOrWhitespace) {
        // viewModel.clearPINVerificationCode(viewModel.device.id);
      }

      return _buildSendVerificationCodeForm(viewModel);
    } else if ((viewModel.device.user.pin != null) &&
        !viewModel.device.user.pin.verificationCode.isNullEmptyOrWhitespace &&
        now.isBefore(viewModel.device.user.pin.verificationExpireDate)) {
      return _buildCodeVerificationForm(viewModel);
    }

    return Spinner();
  }

  /// Builds the 'phone number' message
  Widget _buildPhoneNumberMessage(
    DeviceViewModel viewModel,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context)
                  .enterPhoneNumber(PINConfig.VERIFICATION_CODE_LENGTH),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          _buildPhoneNumberForm(viewModel),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: FormButton(
              text: AppLocalizations.of(context).updatePhoneNumber,
              onPressed: () => _tapSavePhoneNumber(viewModel),
            ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => _tapCancel(viewModel),
            textColor: AppTheme.accent,
          ),
        ],
      );

  /// Builds the 'phone number' form
  Widget _buildPhoneNumberForm(
    DeviceViewModel viewModel,
  ) {
    List<Widget> tiles = [];
    tiles
      ..add(
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
          ),
          child: InternationalPhoneNumberInput(
            locale: 'en_US', // TODO!
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ignoreBlank: true,
            autoValidate: false,
            initialValue:
                viewModel.device.user.phone.phoneNumber.isNullEmptyOrWhitespace
                    ? PhoneNumber(isoCode: 'US') // TODO!
                    : viewModel.device.user.phone.toPhoneNumber(),
            selectorTextStyle: Theme.of(context).textTheme.bodyText1,
            textFieldController: _phoneController,
            inputDecoration: InputDecoration(
              border: UnderlineInputBorder(),
            ),
          ),
        ),
      );

    return Form(
      key: _phoneNumberFormKey,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: tiles,
      ),
    );
  }

  /// Builds the 'send verification code' form
  Widget _buildSendVerificationCodeForm(
    DeviceViewModel viewModel,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context).sendPinVerificationCodeText(
                PINConfig.VERIFICATION_CODE_LENGTH,
                PINConfig.VERIFICATION_CODE_EXPIRE_MINUTES,
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Text(
            viewModel.device.user.phone.toPhoneNumber().phoneNumber,
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: Text(
              AppLocalizations.of(context).enterPhoneNumberDisclaimer,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: FormButton(
              text: AppLocalizations.of(context).sendCode,
              onPressed: () => _tapSaveVerificationCode(viewModel),
            ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => _tapCancel(
              viewModel,
              clearVerificationCode: true,
            ),
            textColor: AppTheme.accent,
          ),
        ],
      );

  /// Builds the 'code verification' form
  Widget _buildCodeVerificationForm(
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
              AppLocalizations.of(context).verifyPinVerificationCodeText(
                  PINConfig.VERIFICATION_CODE_LENGTH),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Container(
            child: PinCodeTextField(
              key: Key('verificationCodeKey'),
              keyboardType: TextInputType.number,
              maxLength: PINConfig.VERIFICATION_CODE_LENGTH,
              spacerIndex: 0,
              onTextChanged: (text) => setState(() => _verificationCode =
                  (text.length == PINConfig.VERIFICATION_CODE_LENGTH)
                      ? text
                      : null),
              onDone: (text) => setState(() => _verificationCode = text),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: FormButton(
              color: AppTheme.primary,
              text: AppLocalizations.of(context).verifyCode,
              onPressed: (!_verificationCode.isNullEmptyOrWhitespace &&
                      (_verificationCode.length ==
                          PINConfig.VERIFICATION_CODE_LENGTH))
                  ? () => _tapVerifyVerificationCode(viewModel)
                  : null,
            ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).resendCode,
            onPressed: () => _tapCancel(
              viewModel,
              clearVerificationCode: true,
            ),
            textColor: AppTheme.accent,
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => _tapCancel(
              viewModel,
              clearVerificationCode: true,
            ),
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
              text: AppLocalizations.of(context).save,
              onPressed: (!_pinCode.isNullEmptyOrWhitespace &&
                      (_pinCode.length == PINConfig.PIN_CODE_LENGTH))
                  ? () => _tapSavePIN(viewModel)
                  : null,
            ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => _tapCancel(
              viewModel,
              clearVerificationCode: true,
            ),
            textColor: AppTheme.accent,
          ),
        ],
      );

  /// Builds the 'pin code confirmation' form
  Widget _buildPINCodeConfirmation(
    DeviceViewModel viewModel,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context).pinCodeUpdateConfirmationText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: FormButton(
              text: AppLocalizations.of(context).ok,
              onPressed: () => _tapCancel(viewModel),
            ),
          ),
        ],
      );

  /// Handles the 'save phone number' tap
  void _tapSavePhoneNumber(
    DeviceViewModel viewModel,
  ) async {
    if (_phoneNumberFormKey.currentState.validate()) {
      _phoneNumberFormKey.currentState.save();

      Map<dynamic, dynamic> userData = Map<dynamic, dynamic>.from({});

      if (!_phoneController.value.text.isNullEmptyOrWhitespace) {
        PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(
            _phoneController.value.text, 'US'); // TODO!

        Map<dynamic, dynamic> phoneData = Map<dynamic, dynamic>.from({
          'dial_code': number.dialCode,
          'iso_code': number.isoCode,
          'phone_number': number.phoneNumber,
        });

        userData.putIfAbsent('phone', () => phoneData);
      }

      /*
      viewModel.saveDevice(
        viewModel.device.id,
        {
          'user': userData,
        },
        context: context,
      );
      */

      // Close the keyboard if it's open
      FocusScope.of(context).unfocus();
    }
  }

  /// Handles the 'save verification code' tap
  void _tapSaveVerificationCode(
    DeviceViewModel viewModel,
  ) async {
    String verificationCode =
        getRandomNumber(length: PINConfig.VERIFICATION_CODE_LENGTH);
    Uint8List cipheredVerificationCode = encryptString(
      RsaKeyHelper().parsePublicKeyFromPem(viewModel.device.publicKey),
      verificationCode,
    );

    DateTime now = getNow();
    SMS sms = SMS(
      device: viewModel.device.id,
      inboundPhone: viewModel.device.user.phone.phoneNumber,
      body: AppLocalizations.of(context).pinVerificationCodeSMSText(
        AppLocalizations.appTitle,
        verificationCode,
      ),
      sentDate: now,
    );

    /*
    viewModel.savePINVerificationCode(
      viewModel.device.id,
      String.fromCharCodes(cipheredVerificationCode),
      now.add(Duration(minutes: 10)),
      sms,
    );
    */
  }

  /// Handles the 'verify verification code' tap
  void _tapVerifyVerificationCode(
    DeviceViewModel viewModel,
  ) async {
    rsa.RSAPrivateKey privateKey = RsaKeyHelper()
        .parsePrivateKeyFromPem(_prefs.getString(RSAKeys.APP_RSA_KEY));

    String decipheredVerificationCode = decryptString(
      privateKey,
      Uint8List.fromList(viewModel.device.user.pin.verificationCode.codeUnits),
    );

    if (decipheredVerificationCode == _verificationCode) {
      setState(() => _verified = true);

      _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
        text: AppLocalizations.of(context).validVerificationCode,
        type: MessageType.SUCCESS,
      )));
    } else {
      _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
        text: AppLocalizations.of(context).invalidVerificationCode,
        type: MessageType.ERROR,
      )));
    }
  }

  /// Handles the 'save pin' tap
  void _tapSavePIN(
    DeviceViewModel viewModel,
  ) {
    Uint8List cipheredPIN = encryptString(
      RsaKeyHelper().parsePublicKeyFromPem(viewModel.device.publicKey),
      _pinCode,
    );

    /*
    viewModel.savePINCode(
      viewModel.device.id,
      String.fromCharCodes(cipheredPIN),
    );
    */

    setState(() {
      _verified = false;
      _saved = true;
    });

    _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
      text: AppLocalizations.of(context).pinCodeUpdateConfirmationText,
      type: MessageType.SUCCESS,
    )));
  }

  /// Handles the 'cancel' tap
  void _tapCancel(
    DeviceViewModel viewModel, {
    bool clearVerificationCode = false,
  }) {
    if (clearVerificationCode) {
      // viewModel.clearPINVerificationCode(viewModel.device.id);
    }

    Navigator.pop(context);
  }
}
