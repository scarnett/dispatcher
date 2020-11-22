import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays the progress indicator
class Progress extends StatefulWidget {
  final Color backgroundColor;
  final double strokeWidth;
  final double size;

  Progress({
    Key key,
    this.backgroundColor,
    this.strokeWidth = 4.0,
    this.size = 30.0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProgressState();
}

class ProgressState extends State<Progress> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      _buildContent();

  /// Builds the content
  Widget _buildContent() => Center(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor: widget.backgroundColor,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
      );
}
