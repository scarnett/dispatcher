import 'dart:math';
import 'package:circular_menu/circular_menu.dart';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/viewmodel.dart';
import 'package:dispatcher/views/contacts/contacts_view.dart';
import 'package:dispatcher/views/menu/menu_view.dart';
import 'package:dispatcher/views/settings/settings_view.dart';
import 'package:dispatcher/widgets/bottom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';

class HomeView extends StatefulWidget {
  HomeView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  PageController _pageController;

  final List<Widget> _tabContainers = <Widget>[
    Container(),
    ContactsView(),
    SettingsView(),
    MenuView(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, AppViewModel>(
        converter: (store) => AppViewModel.fromStore(store),
        // onInitialBuild: (viewModel) =>
        // askContactsPermissions(viewModel, context),
        builder: (_, viewModel) => WillPopScope(
          onWillPop: () => _willPopCallback(viewModel),
          child: Scaffold(
            extendBody: true,
            body: _buildCirclularMenu(
              child: Column(
                children: _buildContent(viewModel),
              ),
            ),
          ),
        ),
      );

  /// Handles the android back button
  Future<bool> _willPopCallback(
    AppViewModel viewModel,
  ) async {
    setState(() {
      if (viewModel.selectedTabIndex == 0) {
        // Exits the app
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {
        // Go back to the first tab
        viewModel.setSelectedTabIndex(0);
        _pageController.jumpToPage(0);
      }
    });

    return false;
  }

  List<Widget> _buildContent(
    AppViewModel viewModel,
  ) {
    List<Widget> children = [];
    children..add(_buildBody(viewModel));
    children
      ..add(
        BottomNavBar(
          color: AppTheme.hint,
          onTabSelected: (index) => _selectedTab(index),
          items: [
            BottomNavBarItem(
              iconData: Icons.home,
              text: AppLocalizations.of(context).home,
            ),
            BottomNavBarItem(
              iconData: Icons.people,
              text: AppLocalizations.of(context).contacts,
            ),
            BottomNavBarItem(
              iconData: Icons.settings,
              text: AppLocalizations.of(context).settings,
            ),
            BottomNavBarItem(
              iconData: Icons.view_list,
              text: AppLocalizations.of(context).menu,
            ),
          ],
        ),
      );

    return children;
  }

  Widget _buildBody(
    AppViewModel viewModel,
  ) =>
      Expanded(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) => viewModel.setSelectedTabIndex(index),
          children: _tabContainers,
        ),
      );

  CircularMenu _buildCirclularMenu({
    Widget child,
  }) =>
      CircularMenu(
        alignment: Alignment.bottomCenter,
        toggleButtonAnimatedIconData: AnimatedIcons.menu_close,
        toggleButtonMargin: 10.0,
        toggleButtonPadding: 10.0,
        toggleButtonSize: 20.0,
        toggleButtonBoxShadow: [
          BoxShadow(
            blurRadius: 0,
          ),
        ],
        startingAngleInRadian: (1.25 * pi),
        endingAngleInRadian: (1.75 * pi),
        radius: 100.0,
        items: [
          _buildCircularMenuItem(
            Icons.add_comment,
            AppLocalizations.of(context).sendMessage,
            () => {},
          ),
          _buildCircularMenuItem(
            Icons.person_add,
            AppLocalizations.of(context).connect,
            _tapConnect,
          ),
          _buildCircularMenuItem(
            Icons.whatshot,
            'What\'s Hot',
            () => {},
          ),
        ],
        backgroundWidget: (child == null) ? Container() : child,
      );

  CircularMenuItem _buildCircularMenuItem(
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) =>
      CircularMenuItem(
        onTap: onTap,
        icon: icon,
        iconSize: 20.0,
        margin: 0.0,
        padding: 10.0,
        boxShadow: [
          BoxShadow(
            blurRadius: 0,
          ),
        ],
      );

  void _selectedTab(
    int index,
  ) =>
      _pageController.jumpToPage(index);

  _tapConnect() => StoreProvider.of<AppState>(context)
      .dispatch(NavigatePushAction(AppRoutes.connect));
}
