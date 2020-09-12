import 'package:dispatcher/localization.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/auth_widgets.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:flutter/material.dart';

/// Displays the auth login view
class AuthLoginView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final PageController pageController;

  AuthLoginView({
    Key key,
    this.scaffoldKey,
    this.pageController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthLoginViewState();
}

class _AuthLoginViewState extends State<AuthLoginView> {
  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> items = [
      AuthFormMode.LOGIN.getForm(widget.scaffoldKey),
      _buildCreateButton(),
    ];

    return wrapAuthPage(items);
  }

  /// Builds the create button
  Widget _buildCreateButton() => FormButton(
        color: Colors.transparent,
        text: AppLocalizations.of(context).dontHaveAccount,
        onPressed: _tapCreate,
        textColor: AppTheme.accent,
      );

  /// Handles the 'create' tap
  void _tapCreate() {
    moveToPage(widget.pageController, AuthFormMode.CREATE);
  }
}
