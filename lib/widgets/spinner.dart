import 'package:dispatcher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays the loading spinner
class Spinner extends StatefulWidget {
  final bool fill;
  final Color fillColor;
  final String message;
  final bool centered;

  Spinner({
    Key key,
    this.fill: false,
    this.fillColor,
    this.message,
    this.centered = true,
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

    if (widget.fill) {
      return Positioned.fill(
        child: _buildContainer(children),
      );
    }

    return _buildContainer(children);
  }

  Widget _buildContainer(
    List<Widget> children,
  ) =>
      Container(
        color:
            (widget.fillColor == null) ? AppTheme.background : widget.fillColor,
        child: _buildContainerWrapper(children),
      );

  Widget _buildContainerWrapper(
    List<Widget> children,
  ) {
    if (widget.centered) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
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
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
