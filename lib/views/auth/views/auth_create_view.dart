import 'package:dispatcher/localization.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/auth_widgets.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:flutter/material.dart';

/// Displays the auth create view
class AuthCreateView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final PageController pageController;

  AuthCreateView({
    Key key,
    this.scaffoldKey,
    this.pageController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthCreateViewState();
}

class _AuthCreateViewState extends State<AuthCreateView> {
  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> items = [
      AuthFormMode.CREATE.getForm(widget.scaffoldKey),
      _buildLoginButton(),
    ];

    return wrapAuthPage(items);
  }

  /// Builds the login button
  Widget _buildLoginButton() => FormButton(
        color: Colors.transparent,
        text: AppLocalizations.of(context).alreadyHaveAccount,
        onPressed: _tapLogin,
        textColor: AppTheme.accent,
      );

  /// Handles the 'login' tap
  void _tapLogin() {
    moveToPage(widget.pageController, AuthFormMode.LOGIN);
  }
}
