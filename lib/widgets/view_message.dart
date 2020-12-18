import 'package:dispatcher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays a view message
class ViewMessage extends StatefulWidget {
  final bool fill;
  final Color fillColor;
  final String message;
  final Color messageColor;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final bool centered;
  final bool showSpinner;
  final bool showButton;
  final String buttonText;
  final Function buttonOnPressed;

  ViewMessage({
    Key key,
    this.fill: false,
    this.fillColor,
    this.message,
    this.messageColor = AppTheme.accent,
    this.icon,
    this.iconColor = AppTheme.primary,
    this.iconSize = 70.0,
    this.centered = true,
    this.showSpinner = true,
    this.showButton = false,
    this.buttonText,
    this.buttonOnPressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ViewMessageState();
}

class ViewMessageState extends State<ViewMessage> {
  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> children = <Widget>[];

    if (widget.showSpinner) {
      children.add(_buildSpinner());
    } else if (widget.icon != null) {
      children.add(_buildIcon());
    }

    if (widget.message != null) {
      children.add(_buildMessage());
    }

    if (widget.showButton) {
      children.add(
        FlatButton(
          color: AppTheme.primary,
          child: Text(widget.buttonText),
          onPressed: widget.buttonOnPressed,
        ),
      );
    }

    if (widget.fill) {
      return Positioned.fill(
        child: _buildContainer(children),
      );
    }

    return _buildContainer(children);
  }

  /// Builds the container
  Widget _buildContainer(
    List<Widget> children,
  ) =>
      Container(
        color:
            (widget.fillColor == null) ? AppTheme.background : widget.fillColor,
        child: _buildContainerWrapper(children),
      );

  /// Builds the container wrapper
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

  /// Builds the spinner
  Widget _buildSpinner() {
    if (widget.icon != null) {
      return Stack(children: <Widget>[
        CircularProgressIndicator(),
        _buildIcon(),
      ]);
    }

    return CircularProgressIndicator();
  }

  /// Builds the icon
  Widget _buildIcon() => Icon(
        widget.icon,
        color: widget.iconColor,
        size: widget.iconSize,
      );

  /// Builds the message
  Widget _buildMessage() => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          widget.message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: widget.messageColor,
              ),
        ),
      );
}
