import 'dart:async';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/bloc/auth.dart';
import 'package:dispatcher/views/auth/views/auth_login_view.dart';
import 'package:dispatcher/views/auth/views/auth_create_view.dart';
import 'package:dispatcher/views/auth/widgets/auth_wrapper.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Displays the auth view
class AuthView extends StatefulWidget {
  AuthView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(
      initialPage: 0,
    );

    super.initState();
  }

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    _pageController?.dispose();
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
            WillPopScope(
          onWillPop: () => _willPopCallback(),
          child: _getContent(state),
        ),
      );

  Future<bool> _willPopCallback() {
    if (_pageController.page.round() > 0) {
      moveToPage(_pageController, AuthFormMode.LOGIN);
      return Future.value(false);
    }

    return Future.value(true);
  }

  Widget _getContent(
    AuthState state,
  ) =>
      Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            AnimatedBuilder(
              animation: _pageController,
              builder: (context, _) => Container(
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: <Widget>[
                    _buildLogo(),
                    PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: _getPages(),
                    ),
                  ],
                ),
              ),
            ),
            _buildLoader(state),
          ],
        ),
      );

  List<Widget> _getPages() {
    List<Widget> pages = [];
    pages
      ..add(
        AuthLoginView(
          scaffoldKey: _scaffoldKey,
          pageController: _pageController,
        ),
      )
      ..add(
        AuthCreateView(
          scaffoldKey: _scaffoldKey,
          pageController: _pageController,
        ),
      );

    return pages;
  }

  /// Builds the logo
  Widget _buildLogo() => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 50.0,
        ),
        child: Material(
          elevation: 1.0,
          shape: CircleBorder(),
          child: CircleAvatar(
            backgroundColor: Colors.grey[50],
            // TODO!
            child: FlutterLogo(
              size: 50.0,
            ),
            radius: 50.0,
          ),
        ),
      );

  Widget _buildLoader(
    AuthState state,
  ) {
    if (state != null) {
      if (state.authorizing) {
        return Spinner(
          fill: true,
          message: AppLocalizations.of(context).authorizing,
        );
      } else if (state.creating) {
        return Spinner(
          fill: true,
          message: AppLocalizations.of(context).creating,
        );
      }
    }

    return Container();
  }
}
