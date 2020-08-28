import 'package:dispatcher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Color color;
  final int value;

  const Badge({
    Key key,
    this.color: AppTheme.accent,
    this.value,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      Container(
        width: 16.0,
        height: 16.0,
        padding: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 1.0,
          ),
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 8.0,
            ),
          ),
        ),
      );
}
