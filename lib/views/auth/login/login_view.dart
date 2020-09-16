import 'package:dispatcher/localization.dart';
import 'package:dispatcher/repository/auth_repository.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/auth/login/bloc/bloc.dart';
import 'package:dispatcher/views/auth/widgets/auth_wrapper.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Displays the auth login view
class AuthLoginView extends StatefulWidget {
  final PageController pageController;

  AuthLoginView({
    Key key,
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
      AuthFormMode.LOGIN.getForm(),
      _buildCreateButton(),
    ];

    return Scaffold(
      body: BlocProvider<LoginBloc>(
        create: (BuildContext context) => LoginBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        ),
        child: wrapAuthPage(items),
      ),
    );
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
    AuthFormMode mode = AuthFormMode.CREATE;
    context.bloc<AuthBloc>().add(SetAuthFormMode(mode));
    moveToPage(widget.pageController, mode);
  }
}
