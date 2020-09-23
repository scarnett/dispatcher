import 'package:dispatcher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays the loading spinner
class Spinner extends StatefulWidget {
  final bool fill;
  final Color fillColor;
  final String message;

  Spinner({
    Key key,
    this.fill: false,
    this.fillColor,
    this.message,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SpinnerState();
}

class SpinnerState extends State<Spinner> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      _buildContent();

  /// Builds the content
  Widget _buildContent() {
    List<Widget> children = <Widget>[];
    children..add(_buildSpinner());

    if (widget.message != null) {
      children..add(_buildMessage());
    }

    return Container(
      color: (widget.fillColor == null)
          ? AppTheme.loadingBackground
          : widget.fillColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  /// Builds the 'loading' spinner
  Widget _buildSpinner() => CircularProgressIndicator();

  /// Builds the 'loading' message
  Widget _buildMessage() => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          widget.message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: AppTheme.accent,
              ),
        ),
      );
}
