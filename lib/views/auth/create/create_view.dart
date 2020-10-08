import 'package:dispatcher/localization.dart';
import 'package:dispatcher/repository/auth_repository.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/create/bloc/bloc.dart';
import 'package:dispatcher/views/auth/widgets/auth_wrapper.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Displays the auth create view
class AuthCreateView extends StatefulWidget {
  final PageController pageController;

  AuthCreateView({
    Key key,
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
      AuthFormMode.CREATE.getForm(),
      _buildLoginButton(),
    ];

    return Scaffold(
      body: BlocProvider<CreateAccountBloc>(
        create: (BuildContext context) => CreateAccountBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        ),
        child: wrapAuthPage(items),
      ),
    );
  }

  /// Builds the login button
  Widget _buildLoginButton() => FormButton(
        color: Colors.transparent,
        text: AppLocalizations.of(context).alreadyHaveAccount,
        onPressed: () => moveToPage(widget.pageController, AuthFormMode.LOGIN),
        textColor: AppTheme.accent,
        textButton: true,
      );
}
