import 'package:dispatcher/actions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:logger/logger.dart';
import 'package:redux/redux.dart';

/// Builds the auth login form
class AuthLoginForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  AuthLoginForm({
    Key key,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends State<AuthLoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Logger logger = Logger();

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _buildEmailField(),
            _buildPasswordField(),
            _buildLoginButton(),
          ],
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
          validator: (value) =>
              (value.isEmpty) ? AppLocalizations.of(context).emailPlease : null,
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
          validator: (value) => (value.isEmpty)
              ? AppLocalizations.of(context).passwordPlease
              : null,
        ),
      );

  /// Builds the login button
  Widget _buildLoginButton() => Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 10.0,
        ),
        child: FormButton(
          text: AppLocalizations.of(context).login,
          onPressed: _tapLogin,
        ),
      );

  /// Handles the 'login' tap
  void _tapLogin() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    final Store store = StoreProvider.of<AppState>(context);
    store.dispatch(SetAppBusyStatusAction(true));

    _formKey.currentState.save();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      store.dispatch(SetAppBusyStatusAction(false));
      Navigator.pushNamed(context, AppRoutes.landing.name);
    } catch (e) {
      logger.e('Error authenticating the firebase user', e);

      store.dispatch(SetAppBusyStatusAction(false));

      widget.scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
        text: AppLocalizations.of(context).cantAuthAccount,
        type: MessageType.ERROR,
      )));
    }
  }
}
