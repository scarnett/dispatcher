import 'dart:math';
import 'package:circular_menu/circular_menu.dart';
import 'package:dispatcher/graphql/client_provider.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/connect/connect_view.dart';
import 'package:dispatcher/views/contacts/contacts_view.dart';
import 'package:dispatcher/views/home/bloc/home_bloc.dart';
import 'package:dispatcher/views/home/bloc/home_events.dart';
import 'package:dispatcher/views/home/bloc/home_state.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/connections/connections_views.dart';
import 'package:dispatcher/views/dashboard/dashboard_view.dart';
import 'package:dispatcher/views/menu/menu_view.dart';
import 'package:dispatcher/views/settings/settings_view.dart';
import 'package:dispatcher/widgets/bottom_app_bar.dart';
import 'package:dispatcher/widgets/view_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  static Route route() => MaterialPageRoute<void>(builder: (_) => HomeView());

  const HomeView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      ClientProvider(
        child: BlocProvider<HomeBloc>(
          create: (BuildContext context) {
            context.bloc<AuthBloc>()
              ..add(LoadUser(Provider.of<GraphQLClient>(
                context,
                listen: false,
              )))
              ..add(ConfigureNotifications());

            return HomeBloc();
          },
          child: HomePageView(),
        ),
      );
}

class HomePageView extends StatefulWidget {
  HomePageView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final GlobalKey<CircularMenuState> _bottomMenuKey =
      GlobalKey<CircularMenuState>();

  PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: context.bloc<HomeBloc>().state.selectedTabIndex,
    );
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
      BlocBuilder<HomeBloc, HomeState>(
        builder: (
          BuildContext context,
          HomeState state,
        ) =>
            WillPopScope(
          onWillPop: () => _willPopCallback(state),
          child: Scaffold(
            extendBody: true,
            body: _buildContent(state),
          ),
        ),
      );

  /// Handles the android back button
  Future<bool> _willPopCallback(
    HomeState state,
  ) async {
    setState(() {
      if (state.selectedTabIndex == 0) {
        // Exits the app
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {
        // Go back to the first tab
        context.bloc<HomeBloc>().add(SelectedTabIndex(0));
        _pageController.jumpToPage(0);
      }
    });

    return Future.value(false);
  }

  /// Builds the content
  Widget _buildContent(
    HomeState state,
  ) {
    if ((state == null) || (context.bloc<AuthBloc>().state.user == null)) {
      return ViewMessage(
        message: AppLocalizations.of(context).loadingUser,
      );
    }

    List<Widget> children = [];
    children..add(_buildBody());
    children..add(_buildBottomNavBar(state));

    return _buildCirclularMenu(
      child: Column(
        children: children,
      ),
    );
  }

  /// Builds the pageview
  Widget _buildBody() => Expanded(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: _tapPageTab,
          children: _getTabContainers(),
        ),
      );

  /// Builds the bottom navbar
  Widget _buildBottomNavBar(
    HomeState state,
  ) =>
      BottomNavBar(
        color: AppTheme.hint,
        onTabSelected: (index) => _selectedTab(index),
        selectedIndex: state.selectedTabIndex,
        items: [
          BottomNavBarItem(
            iconData: Icons.dashboard,
            text: AppLocalizations.of(context).dashboard,
          ),
          BottomNavBarItem(
            iconData: Icons.people,
            text: AppLocalizations.of(context).connections,
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
      );

  /// Builds the circular menu
  CircularMenu _buildCirclularMenu({
    Widget child,
  }) =>
      CircularMenu(
        key: _bottomMenuKey,
        alignment: Alignment.bottomCenter,
        toggleButtonAnimatedIconData: AnimatedIcons.menu_close,
        toggleButtonMargin: 10.0,
        toggleButtonPadding: 10.0,
        toggleButtonSize: 20.0,
        toggleButtonBoxShadow: [
          BoxShadow(blurRadius: 0),
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
            Icons.contacts,
            AppLocalizations.of(context).contacts,
            _tapContacts,
          ),
        ],
        backgroundWidget: (child == null) ? Container() : child,
      );

  /// Builds a circular menu item
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
          BoxShadow(blurRadius: 0),
        ],
      );

  /// Gets the tab containers
  List<Widget> _getTabContainers() => <Widget>[
        DashboardView(),
        ConnectionsView(),
        SettingsView(),
        MenuView(pageController: _pageController),
      ];

  /// Handles a selected tab event
  void _selectedTab(
    int index,
  ) {
    _bottomMenuKey.currentState.reverseAnimation();
    _pageController.jumpToPage(index);
  }

  /// Handles the 'page tab' tap
  _tapPageTab(
    int index,
  ) {
    _bottomMenuKey.currentState.reverseAnimation();
    context.bloc<HomeBloc>().add(SelectedTabIndex(index));
  }

  /// Handles the 'connect' tap
  _tapConnect() {
    _bottomMenuKey.currentState.reverseAnimation();
    Navigator.push(context, ConnectView.route());
  }

  /// Handles the 'contacts' tap
  _tapContacts() {
    _bottomMenuKey.currentState.reverseAnimation();
    Navigator.push(context, ContactsView.route());
  }
}
