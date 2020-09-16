import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/auth/login/bloc/bloc.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

/// Builds the auth login form
class AuthLoginForm extends StatefulWidget {
  AuthLoginForm({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends State<AuthLoginForm> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocListener<LoginBloc, LoginState>(
        listener: (
          BuildContext context,
          LoginState state,
        ) {
          if (state.status.isSubmissionFailure) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                buildSnackBar(Message(
                  text: AppLocalizations.of(context).cantAuthAccount,
                  type: MessageType.ERROR,
                )),
              );
          }
        },
        child: Column(
          children: <Widget>[
            _buildEmailField(),
            _buildPasswordField(),
            _buildLoginButton(),
          ],
        ),
      );

  /// Builds the 'email' field
  Widget _buildEmailField() => BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => (previous.email != current.email),
        builder: (context, state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 10.0,
          ),
          child: CustomTextField(
            key: const Key('loginForm_emailInput_textField'),
            label: AppLocalizations.of(context).email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (email) =>
                context.bloc<LoginBloc>().add(LoginEmailChanged(email)),
            errorText: state.email.invalid
                ? AppLocalizations.of(context).emailPlease
                : null,
          ),
        ),
      );

  /// Builds the 'password' field
  Widget _buildPasswordField() => BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) =>
            (previous.password != current.password),
        builder: (context, state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 10.0,
          ),
          child: CustomTextField(
            key: const Key('loginForm_passwordInput_textField'),
            label: AppLocalizations.of(context).password,
            obscureText: true,
            onChanged: (password) =>
                context.bloc<LoginBloc>().add(LoginPasswordChanged(password)),
            errorText: state.email.invalid
                ? AppLocalizations.of(context).passwordPlease
                : null,
          ),
        ),
      );

  /// Builds the login button
  Widget _buildLoginButton() => BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => (previous.status != current.status),
        builder: (context, state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 10.0,
          ),
          child: state.status.isSubmissionInProgress
              ? const CircularProgressIndicator()
              : FormButton(
                  key: const Key('loginForm_login_formButton'),
                  text: AppLocalizations.of(context).login,
                  onPressed: state.status.isValidated
                      ? () =>
                          context.bloc<LoginBloc>().add(const LoginSubmitted())
                      : null,
                ),
        ),
      );
}
