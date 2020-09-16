import 'dart:async';
import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:dispatcher/views/auth/login/login_view.dart';
import 'package:dispatcher/views/auth/create/create_view.dart';
import 'package:dispatcher/views/auth/widgets/auth_wrapper.dart';
import 'package:flutter/material.dart';

/// Displays the auth view
class AuthView extends StatefulWidget {
  static Route route() => MaterialPageRoute<void>(builder: (_) => AuthView());

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
      WillPopScope(
        onWillPop: () => _willPopCallback(),
        child: _getContent(),
      );

  Future<bool> _willPopCallback() {
    if (_pageController.page.round() > 0) {
      moveToPage(_pageController, AuthFormMode.LOGIN);
      return Future.value(false);
    }

    return Future.value(true);
  }

  Widget _getContent() => Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: AnimatedBuilder(
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
      );

  List<Widget> _getPages() {
    List<Widget> pages = [];
    pages
      ..add(
        AuthLoginView(
          pageController: _pageController,
        ),
      )
      ..add(
        AuthCreateView(
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
}
