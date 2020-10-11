import 'package:dispatcher/localization.dart';
import 'package:dispatcher/views/settings/bloc/settings_bloc.dart';
import 'package:dispatcher/views/settings/settings_form.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Displays the settings view
class SettingsView extends StatelessWidget {
  const SettingsView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocProvider<SettingsBloc>(
        create: (BuildContext context) => SettingsBloc(),
        child: SettingsPageView(),
      );
}

class SettingsPageView extends StatefulWidget {
  SettingsPageView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageViewState();
}

class _SettingsPageViewState extends State<SettingsPageView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocBuilder<SettingsBloc, SettingsState>(
        builder: (
          BuildContext context,
          SettingsState state,
        ) =>
            Scaffold(
          key: _scaffoldKey,
          appBar: SimpleAppBar(
            height: 80.0,
            automaticallyImplyLeading: false,
            title: AppLocalizations.of(context).settings,
          ),
          body: SettingsForm(
            scaffoldState: _scaffoldKey.currentState,
          ),
        ),
      );
}
