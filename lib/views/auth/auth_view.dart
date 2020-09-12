import 'dart:async';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/auth_viewmodel.dart';
import 'package:dispatcher/views/auth/auth_widgets.dart';
import 'package:dispatcher/views/auth/views/auth_login_view.dart';
import 'package:dispatcher/views/auth/views/auth_create_view.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

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
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, AuthViewModel>(
        converter: (store) => AuthViewModel.fromStore(store),
        builder: (_, viewModel) => WillPopScope(
          onWillPop: () => _willPopCallback(),
          child: _getContent(viewModel),
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
    AuthViewModel viewModel,
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
                      children: _getPages(viewModel),
                    ),
                  ],
                ),
              ),
            ),
            _buildLoader(viewModel),
          ],
        ),
      );

  List<Widget> _getPages(
    AuthViewModel viewModel,
  ) {
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
    AuthViewModel viewModel,
  ) {
    if (viewModel.busy) {
      return Spinner(
        fill: true,
        message: AppLocalizations.of(context).authorizing, // TODO!
      );
    }

    return Container();
  }
}
