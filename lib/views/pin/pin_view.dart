import 'dart:typed_data';
import 'package:dispatcher/extensions/string_extensions.dart';
import 'package:dispatcher/hive.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/rsa/rsa_key_helper.dart';
import 'package:dispatcher/rsa/rsa_utils.dart';
import 'package:dispatcher/sms/sms_model.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/date_utils.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/pin/bloc/pin_bloc.dart';
import 'package:dispatcher/views/pin/bloc/pin_state.dart';
import 'package:dispatcher/views/pin/pin_config.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/pin_code.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pointycastle/export.dart' as rsa;

// Displays the 'PIN' view
class PINView extends StatelessWidget {
  static Route route() => MaterialPageRoute<void>(builder: (_) => PINView());

  const PINView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocProvider<PINBloc>(
        create: (BuildContext context) => PINBloc(),
        child: PINPageView(),
      );
}

class PINPageView extends StatefulWidget {
  PINPageView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PINPageViewState();
}

class _PINPageViewState extends State<PINPageView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _phoneNumberFormKey = GlobalKey<FormState>();
  TextEditingController _phoneController = TextEditingController();

  bool _verified = false;
  bool _saved = false;
  String _verificationCode;
  String _pinCode;

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocBuilder<PINBloc, PINState>(
        builder: (
          BuildContext context,
          PINState state,
        ) =>
            Scaffold(
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
                  _buildBody(),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _scaffoldKey.currentState.dispose();
    _phoneController.dispose();
    _verified = false;
    _saved = false;
    super.dispose();
  }

  /// Builds the pin body
  Widget _buildBody() {
    DateTime now = getNow();
    User user = context.bloc<AuthBloc>().state.user;

    if (_verified) {
      return _buildPINCodeForm();
    } else if (_saved) {
      return _buildPINCodeConfirmation();
    } else if (user.phone.phoneNumber.isNullEmptyOrWhitespace) {
      return _buildPhoneNumberMessage();
    } else if ((user.pin?.pinCode == null) ||
        user.pin.verificationCode.isNullEmptyOrWhitespace ||
        now.isAfter(user.pin.verificationExpireDate)) {
      if (!user.pin.verificationCode.isNullEmptyOrWhitespace) {
        // viewModel.clearPINVerificationCode(viewModel.device.id);
      }

      return _buildSendVerificationCodeForm();
    } else if ((user.pin != null) &&
        !user.pin.verificationCode.isNullEmptyOrWhitespace &&
        now.isBefore(user.pin.verificationExpireDate)) {
      return _buildCodeVerificationForm();
    }

    return Spinner();
  }

  /// Builds the 'phone number' message
  Widget _buildPhoneNumberMessage() => Column(
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
          _buildPhoneNumberForm(),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: FormButton(
              text: AppLocalizations.of(context).updatePhoneNumber,
              onPressed: () => _tapSavePhoneNumber(),
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

  /// Builds the 'phone number' form
  Widget _buildPhoneNumberForm() {
    User user = context.bloc<AuthBloc>().state.user;
    List<Widget> tiles = []..add(
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
            initialValue: user.phone.phoneNumber.isNullEmptyOrWhitespace
                ? PhoneNumber(isoCode: 'US') // TODO!
                : user.phone.toPhoneNumber(),
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
  Widget _buildSendVerificationCodeForm() => Column(
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
            context
                .bloc<AuthBloc>()
                .state
                .user
                .phone
                .toPhoneNumber()
                .phoneNumber,
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
              onPressed: () => _tapSaveVerificationCode(),
            ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => _tapCancel(
              clearVerificationCode: true,
            ),
            textColor: AppTheme.accent,
          ),
        ],
      );

  /// Builds the 'code verification' form
  Widget _buildCodeVerificationForm() => Column(
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
              text: AppLocalizations.of(context).verifyCode,
              onPressed: (!_verificationCode.isNullEmptyOrWhitespace &&
                      (_verificationCode.length ==
                          PINConfig.VERIFICATION_CODE_LENGTH))
                  ? () => _tapVerifyVerificationCode()
                  : null,
            ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).resendCode,
            onPressed: () => _tapCancel(
              clearVerificationCode: true,
            ),
            textColor: AppTheme.accent,
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => _tapCancel(
              clearVerificationCode: true,
            ),
            textColor: AppTheme.accent,
          ),
        ],
      );

  /// Builds the 'pin code' form
  Widget _buildPINCodeForm() => Column(
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
                  ? () => _tapSavePIN()
                  : null,
            ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: () => _tapCancel(
              clearVerificationCode: true,
            ),
            textColor: AppTheme.accent,
          ),
        ],
      );

  /// Builds the 'pin code confirmation' form
  Widget _buildPINCodeConfirmation() => Column(
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
              onPressed: () => _tapCancel(),
            ),
          ),
        ],
      );

  /// Handles the 'save phone number' tap
  void _tapSavePhoneNumber() async {
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
  void _tapSaveVerificationCode() async {
    User user = context.bloc<AuthBloc>().state.user;
    String verificationCode =
        getRandomNumber(length: PINConfig.VERIFICATION_CODE_LENGTH);

    Uint8List cipheredVerificationCode = encryptString(
      RsaKeyHelper().parsePublicKeyFromPem(user.key.publicKey),
      verificationCode,
    );

    DateTime now = getNow();
    SMS sms = SMS(
      user: user.identifier,
      inboundPhone: user.phone.phoneNumber,
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
  void _tapVerifyVerificationCode() async {
    User user = context.bloc<AuthBloc>().state.user;
    Box<Dispatcher> appBox = Hive.box<Dispatcher>(HiveBoxes.APP_BOX);

    rsa.RSAPrivateKey privateKey =
        RsaKeyHelper().parsePrivateKeyFromPem(appBox.getAt(0).privateKey);

    String decipheredVerificationCode = decryptString(
      privateKey,
      Uint8List.fromList(user.pin.verificationCode.codeUnits),
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
  void _tapSavePIN() {
    User user = context.bloc<AuthBloc>().state.user;
    Uint8List cipheredPIN = encryptString(
      RsaKeyHelper().parsePublicKeyFromPem(user.key.publicKey),
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
  void _tapCancel({
    bool clearVerificationCode = false,
  }) {
    if (clearVerificationCode) {
      // viewModel.clearPINVerificationCode(viewModel.device.id);
    }

    Navigator.pop(context);
  }
}
