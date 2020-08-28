import 'package:dispatcher/actions.dart';
import 'package:dispatcher/keys.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/contacts/contacts_utils.dart';
import 'package:dispatcher/views/contacts/contacts_view.dart';
import 'package:dispatcher/views/contacts/contacts_viewmodel.dart';
import 'package:dispatcher/views/menu/menu_view.dart';
import 'package:dispatcher/views/settings/settings_view.dart';
import 'package:dispatcher/widgets/badge_icon.dart';
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
  int _currentTabIndex = 0;
  PageController _pageController;

  final List<Widget> _tabContainers = <Widget>[
    Container(),
    ContactsView(),
    Container(),
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
      StoreConnector<AppState, ContactsViewModel>(
        converter: (store) => ContactsViewModel.fromStore(store),
        onInitialBuild: (viewModel) =>
            askContactsPermissions(viewModel, context),
        builder: (_, viewModel) => WillPopScope(
          onWillPop: _willPopCallback,
          child: Scaffold(
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) =>
                  setState(() => _currentTabIndex = index),
              children: _tabContainers,
            ),
            bottomNavigationBar: BottomNavigationBar(
              key: AppKeys.appBottomNavKey,
              currentIndex: _currentTabIndex,
              onTap: tapTab,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text(AppLocalizations.of(context).home),
                ),
                BottomNavigationBarItem(
                  icon: BadgeIcon(
                    icon: Icons.people,
                    value: viewModel.contacts.length,
                  ),
                  title: Text(AppLocalizations.of(context).contacts),
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 5.0,
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primary,
                      size: 36.0,
                    ),
                  ),
                  title: Container(),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  title: Text(AppLocalizations.of(context).settings),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  title: Text(AppLocalizations.of(context).menu),
                ),
              ],
            ),
          ),
        ),
      );

  Future<bool> _willPopCallback() async {
    setState(() {
      if (_currentTabIndex == 0) {
        // Exits the app
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {
        // Use this to go back through each tab one by one.
        // Skip the center bottom nav item '+'
        /*
        if ((_currentTabIndex - 1) == 2) {
          _currentTabIndex = (_currentTabIndex - 2);
        } else {
          _currentTabIndex = (_currentTabIndex - 1);
        }
        */

        // Go back to the first tab
        _currentTabIndex = 0;
        _pageController.jumpToPage(_currentTabIndex);
      }
    });

    return false;
  }

  /// Handles a bottom navigation bar item tap.
  void tapTab(
    int index,
  ) =>
      setState(() {
        _currentTabIndex = index;

        switch (_currentTabIndex) {
          // This is the center bottom nav item '+'
          case 2:
            StoreProvider.of<AppState>(context)
                .dispatch(NavigatePushAction(AppRoutes.connect));

            break;

          default:
            /*
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            */

            _pageController.jumpToPage(index);
            break;
        }
      });
}
