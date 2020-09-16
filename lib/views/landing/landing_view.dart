import 'package:dispatcher/localization.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandingView extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => LandingView());

  @override
  _LandingViewState createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      Scaffold(
        body: Container(
          child: Spinner(
            message: AppLocalizations.of(context).loading,
          ),
        ),
      );
}
