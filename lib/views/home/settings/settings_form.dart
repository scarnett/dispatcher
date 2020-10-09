import 'package:dispatcher/env_config.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/avatar/widgets/avatar_select.dart';
import 'package:dispatcher/views/home/settings/bloc/settings_bloc.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/progress.dart';
import 'package:dispatcher/widgets/section_header.dart';
import 'package:dispatcher/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:logger/logger.dart';

/// Builds the settings form
class SettingsForm extends StatefulWidget {
  final ScaffoldState scaffoldState;

  SettingsForm({
    Key key,
    this.scaffoldState,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  Logger logger = Logger();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    User user = context.bloc<AuthBloc>().state.user;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    context.bloc<SettingsBloc>().add(SettingsChanged(user));
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocListener<SettingsBloc, SettingsState>(
        listener: (
          BuildContext context,
          SettingsState state,
        ) {
          if (state.status.isSubmissionSuccess) {
            widget.scaffoldState
              ..hideCurrentSnackBar()
              ..showSnackBar(
                buildSnackBar(Message(
                  text: AppLocalizations.of(context).settingsUpdated,
                  type: MessageType.SUCCESS,
                )),
              );

            closeKeyboard(context);
          } else if (state.status.isSubmissionFailure) {
            widget.scaffoldState
              ..hideCurrentSnackBar()
              ..showSnackBar(
                buildSnackBar(Message(
                  text: AppLocalizations.of(context).error,
                  type: MessageType.ERROR,
                )),
              );

            closeKeyboard(context);
          }
        },
        child: _buildBody(),
      );

  /// Builds the settings body
  Widget _buildBody() {
    List<Widget> tiles = [];
    tiles
      ..addAll(_buildPersonalDetailsSection())
      ..addAll(_buildAvatarSection())
      ..add(
        Divider(
          indent: 20.0,
          endIndent: 20.0,
        ),
      )
      ..add(_buildButton());

    return Container(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: filterNullWidgets(tiles),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the 'personal details' section
  List<Widget> _buildPersonalDetailsSection() {
    return [
      SectionHeader(
        text: AppLocalizations.of(context).personalDetails,
        borderBottom: true,
        borderTop: true,
      ),
      _buildNameField(),
      _buildEmailField(),
      _buildPhoneNumberField(),
    ];
  }

  /// Builds the 'name' field
  Widget _buildNameField() => BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) => (previous.name != current.name),
        builder: (BuildContext context, SettingsState state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 10.0,
          ),
          child: CustomTextField(
            key: const Key('settingsForm_nameInput_textField'),
            controller: _nameController,
            label: AppLocalizations.of(context).name,
            keyboardType: TextInputType.name,
            onChanged: (name) =>
                context.bloc<SettingsBloc>().add(SettingsNameChanged(name)),
            errorText: state.name.invalid
                ? AppLocalizations.of(context).namePlease
                : null,
          ),
        ),
      );

  /// Builds the 'email' field
  Widget _buildEmailField() => BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) => (previous.email != current.email),
        builder: (BuildContext context, SettingsState state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 10.0,
          ),
          child: CustomTextField(
            key: const Key('settingsForm_emailInput_textField'),
            controller: _emailController,
            label: AppLocalizations.of(context).email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (email) =>
                context.bloc<SettingsBloc>().add(SettingsEmailChanged(email)),
            errorText:
                state.email.invalid ? state.email.getErrorText(context) : null,
          ),
        ),
      );

  /// Builds the 'phone number' field
  Widget _buildPhoneNumberField() => BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) => (previous.phone != current.phone),
        builder: (BuildContext context, SettingsState state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
          ),
          child: InternationalPhoneNumberInput(
            key: const Key('settingsForm_phoneInput_textField'),
            locale: EnvConfig.DISPATCHER_LOCALE,
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            ignoreBlank: true,
            autoValidateMode: AutovalidateMode.disabled,
            initialValue:
                context.bloc<AuthBloc>().state.user.phone.toPhoneNumber(),
            selectorTextStyle: Theme.of(context).textTheme.bodyText1,
            onInputChanged: (phone) =>
                context.bloc<SettingsBloc>().add(SettingsPhoneChanged(phone)),
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

  /// Builds the 'avatar' section
  List<Widget> _buildAvatarSection() {
    return [
      SectionHeader(
        text: AppLocalizations.of(context).avatar,
        borderBottom: true,
        borderTop: true,
      ),
      _buildAvatar(),
    ];
  }

  /// Builds the 'avatar'
  Widget _buildAvatar() => Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: UserSelectAvatar(
          user: context.bloc<AuthBloc>().state.user,
          scaffoldState: widget.scaffoldState,
        ),
      );

  /// Builds the button
  Widget _buildButton() => BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) => (previous.status != current.status),
        builder: (BuildContext context, SettingsState state) => Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
            top: 10.0,
          ),
          child: state.status.isSubmissionInProgress
              ? Progress()
              : FormButton(
                  key: const Key('settingsForm_settings_formButton'),
                  text: AppLocalizations.of(context).save,
                  onPressed: state.status.isValidated
                      ? () => context.bloc<SettingsBloc>().add(
                          SettingsSubmitted(
                              context.bloc<AuthBloc>().state.firebaseUser.uid))
                      : null,
                ),
        ),
      );
}
