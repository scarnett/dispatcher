import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/device/device_viewmodel.dart';
import 'package:dispatcher/device/widgets/device_select_avatar.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/email_utils.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/section_header.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:dispatcher/widgets/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:redux/redux.dart';

/// Displays the settings view
class SettingsView extends StatefulWidget {
  SettingsView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    _formKey.currentState?.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, DeviceViewModel>(
        converter: (store) => DeviceViewModel.fromStore(store),
        onInit: (store) {
          DeviceUser user = store.state.deviceState.device.user;
          _nameController = TextEditingController(text: user.name);
          _emailController = TextEditingController(text: user.email);
        },
        builder: (_, viewModel) => Scaffold(
          key: _scaffoldKey,
          appBar: SimpleAppBar(
            height: 80.0,
            automaticallyImplyLeading: false,
            title: AppLocalizations.of(context).settings,
          ),
          body: Form(
            key: _formKey,
            child: _buildBody(viewModel),
          ),
        ),
      );

  /// Builds the settings body
  Widget _buildBody(
    DeviceViewModel viewModel,
  ) {
    List<Widget> tiles = [];
    tiles
      ..addAll(_buildPersonalDetailsSection(viewModel))
      ..addAll(_buildAvatarSection(viewModel))
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
  List<Widget> _buildPersonalDetailsSection(
    DeviceViewModel viewModel,
  ) {
    return [
      SectionHeader(
        text: AppLocalizations.of(context).personalDetails,
        borderBottom: true,
        borderTop: true,
      ),
      _buildNameField(),
      _buildEmailField(),
      _buildPhoneNumberField(viewModel),
    ];
  }

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
  Widget _buildPhoneNumberField(
    DeviceViewModel viewModel,
  ) =>
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
          initialValue: viewModel.device.user.phone.toPhoneNumber(),
          selectorTextStyle: Theme.of(context).textTheme.bodyText1,
          textFieldController: _phoneController,
          inputDecoration: InputDecoration(
            labelText: AppLocalizations.of(context).phoneNumber,
            border: UnderlineInputBorder(),
          ),
        ),
      );

  /// Builds the 'avatar' section
  List<Widget> _buildAvatarSection(
    DeviceViewModel viewModel,
  ) {
    return [
      SectionHeader(
        text: AppLocalizations.of(context).avatar,
        borderBottom: true,
        borderTop: true,
      ),
      _buildAvatar(viewModel),
    ];
  }

  /// Builds the 'avatar'
  Widget _buildAvatar(
    DeviceViewModel viewModel,
  ) =>
      Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 15.0,
        ),
        child: DeviceSelectAvatar(user: viewModel.device.user), // TODO!
      );

  /// Builds the form button
  Widget _buildButton() => Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 20.0,
          top: 10.0,
        ),
        child: FormButton(
          text: AppLocalizations.of(context).save,
          onPressed: _tapSave,
        ),
      );

  /// Handles the form 'save' tap
  void _tapSave() async {
    if (_formKey.currentState.validate()) {
      // Close the keyboard if it's open
      FocusScope.of(context).unfocus();

      final Store store = StoreProvider.of<AppState>(context);
      store.dispatch(SetAppBusyStatusAction(true));

      _formKey.currentState.save();

      // Gets the phone number data
      PhoneNumber phoneNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(
          _phoneController.value.text, 'US'); // TODO!

      // Builds the user data map
      Map<dynamic, dynamic> userData = Map<dynamic, dynamic>.from({
        'identifier': _firebaseAuth.currentUser.uid,
        'name': _nameController.value.text,
        'email': _emailController.value.text,
        'phone': {
          'dial_code': phoneNumber.dialCode,
          'iso_code': phoneNumber.isoCode,
          'phone_number': phoneNumber.phoneNumber,
        },
      });

      // Runs the 'callableUsersUpdate' Firebase callable function
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'callableUsersUpdate',
      );

      // Post the user data to Firebase
      await callable.call(userData);

      store.dispatch(SetAppBusyStatusAction(false));

      // Success message
      _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
        text: AppLocalizations.of(context).saved,
        type: MessageType.SUCCESS,
      )));
    }
  }
}
