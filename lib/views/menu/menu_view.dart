import 'package:dispatcher/localization.dart';
import 'package:dispatcher/views/auth/auth_view.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/home/bloc/bloc.dart';
import 'package:dispatcher/views/home/bloc/home_bloc.dart';
import 'package:dispatcher/views/home/bloc/home_events.dart';
import 'package:dispatcher/views/pin/pin_view.dart';
import 'package:dispatcher/widgets/list_select_item.dart';
import 'package:dispatcher/widgets/section_header.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

/// Displays the app menu view
class MenuView extends StatefulWidget {
  final PageController pageController;

  MenuView({
    Key key,
    this.pageController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocBuilder<HomeBloc, HomeState>(
        builder: (
          BuildContext context,
          HomeState state,
        ) =>
            Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: SimpleAppBar(
            height: 80.0,
            automaticallyImplyLeading: false,
            title: AppLocalizations.of(context).menu,
          ),
          body: _buildBody(),
        ),
      );

  /// Builds the menu body
  Widget _buildBody() {
    List<Widget> items = []
      ..addAll(_applicationSection())
      ..addAll(_securitySection())
      ..addAll(_accountSection());

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: items,
          ),
        ),
      ],
    );
  }

  /// Builds the 'application' section
  List<Widget> _applicationSection() {
    List<Widget> tiles = [];
    tiles
      ..add(
        SectionHeader(
          text: AppLocalizations.of(context).application,
          borderTop: true,
        ),
      );

    tiles
      ..add(
        ListSelectItem(
          title: AppLocalizations.of(context).settings,
          icon: Icons.settings,
          onTap: _tapSettings,
        ),
      );

    tiles
      ..add(
        ListSelectItem(
          title: AppLocalizations.of(context).permissions,
          icon: Icons.settings_applications,
          onTap: _tapPermissions,
        ),
      );

    tiles
      ..add(
        ListSelectItem(
          title: AppLocalizations.of(context).privacyPolicy,
          icon: Icons.security,
          borderBottom: false,
          onTap: null, // TODO!
        ),
      );

    return tiles;
  }

  /// Builds the 'security' section
  List<Widget> _securitySection() {
    List<Widget> tiles = [];
    tiles
      ..add(
        SectionHeader(
          text: AppLocalizations.of(context).security,
          borderTop: true,
        ),
      );

    tiles
      ..add(
        ListSelectItem(
          title: AppLocalizations.of(context).changePin,
          icon: Icons.lock,
          onTap: _tapChangePIN,
        ),
      );

    tiles
      ..add(
        ListSelectItem(
          title: AppLocalizations.of(context).updateEmail,
          icon: Icons.email,
          onTap: _tapUpdateEmail,
        ),
      );

    tiles
      ..add(
        ListSelectItem(
          title: AppLocalizations.of(context).updatePhoneNumber,
          icon: Icons.phone,
          borderBottom: false,
          onTap: _tapUpdatePhoneNumber,
        ),
      );

    return tiles;
  }

  /// Builds the 'account' section
  List<Widget> _accountSection() {
    List<Widget> tiles = [];
    tiles
      ..add(
        SectionHeader(
          text: AppLocalizations.of(context).account,
          borderTop: true,
        ),
      );

    tiles
      ..add(
        ListSelectItem(
          title: AppLocalizations.of(context).logout,
          icon: Icons.exit_to_app,
          borderBottom: false,
          onTap: _tapLogout,
        ),
      );

    return tiles;
  }

  /// Handles the 'change pin' tap
  void _tapChangePIN() => Navigator.push(context, PINView.route());

  /// Handles the 'change email' tap
  void _tapUpdateEmail() => this._tapSettings();

  /// Handles the 'change phone number' tap
  void _tapUpdatePhoneNumber() => this._tapSettings();

  /// Handles the 'settings' tap
  void _tapSettings() {
    context.bloc<HomeBloc>().add(SelectedTabIndex(2));
    widget.pageController.jumpToPage(2);
  }

  /// Handles the 'permissions' tap
  void _tapPermissions() async => await openAppSettings();

  /// Handles the 'logout' tap
  void _tapLogout() {
    context.bloc<HomeBloc>().add(SelectedTabIndex(0));
    context.bloc<AuthBloc>().add(AuthLogoutRequested());
    Navigator.pushReplacement(context, AuthView.route());
  }
}
