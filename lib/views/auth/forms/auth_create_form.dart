import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/rsa/rsa_key_helper.dart';
import 'package:dispatcher/rsa/rsa_utils.dart';
import 'package:dispatcher/services/shared_preference_service.dart';
import 'package:dispatcher/utils/email_utils.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/auth/bloc/auth.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:logger/logger.dart';
import 'package:pointycastle/export.dart' as rsa;

/// Builds the auth create form
class AuthCreateForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  AuthCreateForm({
    Key key,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthCreateFormState();
}

class _AuthCreateFormState extends State<AuthCreateForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController(text: '');
  TextEditingController _passwordController = TextEditingController(text: '');
  TextEditingController _emailController = TextEditingController(text: '');
  TextEditingController _phoneNumberController =
      TextEditingController(text: '');

  Logger logger = Logger();

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocBuilder<AuthBloc, AuthState>(
        builder: (
          BuildContext context,
          AuthState state,
        ) =>
            Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildNameField(),
              _buildPasswordField(),
              _buildEmailField(),
              _buildPhoneNumberField(),
              _buildCreateButton(),
            ],
          ),
        ),
      );

  /// Builds the 'name' field
  Widget _buildNameField() => Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 10.0,
        ),
        child: CustomTextField(
          controller: _nameController,
          label: AppLocalizations.of(context).name,
          keyboardType: TextInputType.name,
          validator: (value) =>
              (value.isEmpty) ? AppLocalizations.of(context).namePlease : null,
        ),
      );

  /// Builds the 'password' field
  Widget _buildPasswordField() => Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 10.0,
        ),
        child: CustomTextField(
          controller: _passwordController,
          label: AppLocalizations.of(context).password,
          obscureText: true,
          validator: (value) => (value.length < 6) // TODO! config
              ? AppLocalizations.of(context).passwordLength(6) // TODO! config
              : null,
        ),
      );

  /// Builds the 'email' field
  Widget _buildEmailField() => Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 10.0,
        ),
        child: CustomTextField(
          controller: _emailController,
          label: AppLocalizations.of(context).email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            RegExp regex = RegExp(getEmailRegex());
            if (!regex.hasMatch(value)) {
              return AppLocalizations.of(context).emailPlease;
            }

            return null;
          },
        ),
      );

  /// Builds the 'phone number' field
  Widget _buildPhoneNumberField() => Padding(
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
          initialValue: PhoneNumber(isoCode: 'US'), // TODO!
          selectorTextStyle: Theme.of(context).textTheme.bodyText1,
          textFieldController: _phoneNumberController,
          inputDecoration: InputDecoration(
            labelText: AppLocalizations.of(context).phoneNumber,
            border: UnderlineInputBorder(),
          ),
        ),
      );

  /// Builds the create button
  Widget _buildCreateButton() => Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 10.0,
        ),
        child: FormButton(
          text: AppLocalizations.of(context).create,
          onPressed: _tapCreate,
        ),
      );

  /// Handles the 'create' tap
  void _tapCreate() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();
    context.bloc<AuthBloc>().add(SetCreating(true));

    try {
      // Generate the keys
      rsa.AsymmetricKeyPair<rsa.PublicKey, rsa.PrivateKey> keyPair =
          getKeyPair();

      // Store the private key
      await sharedPreferenceService.getSharedPreferencesInstance();
      await sharedPreferenceService
          .setPrivateKey(encodePrivatePem(keyPair.privateKey));

      // Gets the phone number data
      PhoneNumber phoneNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(
          _phoneNumberController.text, 'US'); // TODO!

      // Builds the user data map
      Map<String, dynamic> userData = Map<String, dynamic>.from({
        'displayName': _nameController.text,
        'password': _passwordController.text,
        'email': _emailController.text,
        'phone': {
          'dial_code': phoneNumber.dialCode,
          'iso_code': phoneNumber.isoCode,
          'phone_number': phoneNumber.phoneNumber,
        },
        'pubkey': RsaKeyHelper().encodePublicKeyToPem(keyPair.publicKey)
      });

      // Runs the 'callableUsersCreate' Firebase callable function
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'callableUsersCreate',
      );

      // Post the user data to Firebase
      await callable.call(userData);

      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

      // Signin to Firebase with the user credentials
      await _firebaseAuth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Store the auth token
      await sharedPreferenceService
          .setToken(await _firebaseAuth.currentUser.getIdToken());

      // Navigate
      context.bloc<AuthBloc>().add(SetCreating(false));
      Navigator.pushNamed(context, AppRoutes.landing.name);
    } catch (e) {
      logger.e('Error creating the Firebase user', e);

      context.bloc<AuthBloc>().add(SetCreating(false));

      if (context != null) {
        widget.scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
          text: AppLocalizations.of(context).cantCreateAccount,
          type: MessageType.ERROR,
        )));
      }
    }
  }
}
