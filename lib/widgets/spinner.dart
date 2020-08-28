import 'package:dispatcher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays the loading spinner
class Spinner extends StatelessWidget {
  final bool fill;

  const Spinner({
    Key key,
    this.fill: false,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      _buildContent();

  /// Builds the content
  Widget _buildContent() {
    if (fill) {
      return Positioned.fill(
        child: Container(
          color: AppTheme.loadingBackground,
          child: _buildSpinner(),
        ),
      );
    }

    return _buildSpinner();
  }

  /// Builds the 'loading' spinner
  Widget _buildSpinner() => Center(
        child: CircularProgressIndicator(),
      );
}
