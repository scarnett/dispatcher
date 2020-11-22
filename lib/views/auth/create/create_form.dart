import 'package:dispatcher/env_config.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/auth/create/bloc/bloc.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/progress.dart';
import 'package:dispatcher/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:logger/logger.dart';

/// Builds the auth create form
class AuthCreateForm extends StatefulWidget {
  AuthCreateForm({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthCreateFormState();
}

class _AuthCreateFormState extends State<AuthCreateForm> {
  Logger logger = Logger();

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocListener<CreateAccountBloc, CreateAccountState>(
        listener: (
          BuildContext context,
          CreateAccountState state,
        ) {
          if (state.status.isSubmissionInProgress) {
            closeKeyboard(context);
          } else if (state.status.isSubmissionFailure) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                buildSnackBar(Message(
                  text: AppLocalizations.of(context).cantCreateAccount,
                  type: MessageType.ERROR,
                )),
              );

            closeKeyboard(context);
          }
        },
        child: Column(
          children: <Widget>[
            _buildNameField(),
            _buildPasswordField(),
            _buildEmailField(),
            _buildPhoneNumberField(),
            _buildCreateButton(),
          ],
        ),
      );

  /// Builds the 'name' field
  Widget _buildNameField() =>
      BlocBuilder<CreateAccountBloc, CreateAccountState>(
        buildWhen: (previous, current) => (previous.name != current.name),
        builder: (BuildContext context, CreateAccountState state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 10.0,
          ),
          child: CustomTextField(
            key: const Key('createForm_nameInput_textField'),
            label: AppLocalizations.of(context).name,
            keyboardType: TextInputType.name,
            onChanged: (name) => context
                .bloc<CreateAccountBloc>()
                .add(CreateAccountNameChanged(name)),
            errorText: state.name.invalid
                ? AppLocalizations.of(context).namePlease
                : null,
          ),
        ),
      );

  /// Builds the 'password' field
  Widget _buildPasswordField() =>
      BlocBuilder<CreateAccountBloc, CreateAccountState>(
        buildWhen: (previous, current) =>
            (previous.password != current.password),
        builder: (BuildContext context, CreateAccountState state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 10.0,
          ),
          child: CustomTextField(
            key: const Key('createForm_passwordInput_textField'),
            label: AppLocalizations.of(context).password,
            obscureText: true,
            onChanged: (password) => context
                .bloc<CreateAccountBloc>()
                .add(CreateAccountPasswordChanged(password)),
            errorText: state.password.invalid
                ? state.password.getErrorText(context)
                : null,
          ),
        ),
      );

  /// Builds the 'email' field
  Widget _buildEmailField() =>
      BlocBuilder<CreateAccountBloc, CreateAccountState>(
        buildWhen: (previous, current) => (previous.email != current.email),
        builder: (BuildContext context, CreateAccountState state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 10.0,
          ),
          child: CustomTextField(
            key: const Key('createForm_emailInput_textField'),
            label: AppLocalizations.of(context).email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (email) => context
                .bloc<CreateAccountBloc>()
                .add(CreateAccountEmailChanged(email)),
            errorText:
                state.email.invalid ? state.email.getErrorText(context) : null,
          ),
        ),
      );

  /// Builds the 'phone number' field
  Widget _buildPhoneNumberField() =>
      BlocBuilder<CreateAccountBloc, CreateAccountState>(
        buildWhen: (previous, current) => (previous.phone != current.phone),
        builder: (BuildContext context, CreateAccountState state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
          ),
          child: InternationalPhoneNumberInput(
            key: const Key('createForm_phoneInput_textField'),
            locale: EnvConfig.DISPATCHER_LOCALE,
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            ignoreBlank: true,
            autoValidateMode: AutovalidateMode.disabled,
            initialValue: PhoneNumber(isoCode: EnvConfig.DISPATCHER_ISO_CODE),
            selectorTextStyle: Theme.of(context).textTheme.bodyText1,
            onInputChanged: (phone) => context
                .bloc<CreateAccountBloc>()
                .add(CreateAccountPhoneChanged(phone)),
            inputDecoration: InputDecoration(
              labelText: AppLocalizations.of(context).phoneNumber,
              errorText: state.phone.invalid
                  ? AppLocalizations.of(context).phoneNumberPlease
                  : null,
              border: UnderlineInputBorder(),
            ),
          ),
        ),
      );

  /// Builds the create button
  Widget _buildCreateButton() =>
      BlocBuilder<CreateAccountBloc, CreateAccountState>(
        buildWhen: (previous, current) => (previous.status != current.status),
        builder: (BuildContext context, CreateAccountState state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 10.0,
          ),
          child: state.status.isSubmissionInProgress
              ? Progress()
              : FormButton(
                  key: const Key('createForm_create_formButton'),
                  text: AppLocalizations.of(context).create,
                  onPressed: state.status.isValidated
                      ? () => context
                          .bloc<CreateAccountBloc>()
                          .add(const CreateAccountSubmitted())
                      : null,
                ),
        ),
      );
}
