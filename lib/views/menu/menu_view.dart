import 'package:dispatcher/actions.dart';
import 'package:dispatcher/keys.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/viewmodel.dart';
import 'package:dispatcher/widgets/list_select_item.dart';
import 'package:dispatcher/widgets/section_header.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:permission_handler/permission_handler.dart';

/// Displays the app menu view
class MenuView extends StatefulWidget {
  MenuView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, AppViewModel>(
        converter: (store) => AppViewModel.fromStore(store),
        builder: (_, viewModel) => Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: SimpleAppBar(
            height: 80.0,
            automaticallyImplyLeading: false,
            title: AppLocalizations.of(context).menu,
          ),
          body: _buildBody(viewModel),
        ),
      );

  /// Builds the menu body
  Widget _buildBody(
    AppViewModel viewModel,
  ) {
    List<Widget> items = []
      ..addAll(_applicationSection(viewModel))
      ..addAll(_securitySection(viewModel))
      ..addAll(_migrateSection(viewModel));

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
  List<Widget> _applicationSection(
    AppViewModel viewModel,
  ) {
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
  List<Widget> _securitySection(
    AppViewModel viewModel,
  ) {
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
          onTap: _tapUpdatePhoneNumber,
        ),
      );

    return tiles;
  }

  /// Builds the 'migrate' section
  List<Widget> _migrateSection(
    AppViewModel viewModel,
  ) {
    List<Widget> tiles = [];
    tiles
      ..add(
        SectionHeader(
          text: AppLocalizations.of(context).migrate,
          borderTop: true,
        ),
      );

    tiles
      ..add(
        ListSelectItem(
          title: AppLocalizations.of(context).fromThisDevice,
          icon: Icons.undo,
          onTap: _tapMigrateFrom,
        ),
      );

    tiles
      ..add(
        ListSelectItem(
          title: AppLocalizations.of(context).toThisDevice,
          icon: Icons.redo,
          onTap: _tapMigrateTo,
        ),
      );

    return tiles;
  }

  /// Handles the 'change pin' tap
  void _tapChangePIN() => StoreProvider.of<AppState>(context)
      .dispatch(NavigatePushAction(AppRoutes.changePIN));

  /// Handles the 'change email' tap
  void _tapUpdateEmail() => this._tapSettings();

  /// Handles the 'change phone number' tap
  void _tapUpdatePhoneNumber() => this._tapSettings();

  /// Handles the 'settings' tap
  void _tapSettings() {
    final BottomNavigationBar navigationBar =
        AppKeys.appBottomNavKey.currentWidget;
    navigationBar.onTap(3);
  }

  /// Handles the 'permissions' tap
  void _tapPermissions() async => await openAppSettings();

  /// Handles the 'migrate from' tap
  void _tapMigrateFrom() => StoreProvider.of<AppState>(context)
      .dispatch(NavigatePushAction(AppRoutes.migrateFrom));

  /// Handles the 'migrate to' tap
  void _tapMigrateTo() => StoreProvider.of<AppState>(context)
      .dispatch(NavigatePushAction(AppRoutes.migrateTo));
}
