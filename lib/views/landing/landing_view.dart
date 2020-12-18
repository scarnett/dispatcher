import 'package:dispatcher/localization.dart';
import 'package:dispatcher/widgets/view_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandingView extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => LandingView());

  @override
  _LandingViewState createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(
    BuildContext context,
  ) =>
      Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: ViewMessage(
            message: AppLocalizations.of(context).loading,
          ),
        ),
      );
}
