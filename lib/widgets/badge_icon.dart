import 'package:dispatcher/theme.dart';
import 'package:dispatcher/widgets/badge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final double size;

  const BadgeIcon({
    Key key,
    @required this.icon,
    this.color: AppTheme.accent,
    this.value,
    this.size = 64.0,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> children = <Widget>[];
    children..add(Icon(icon));

    if (value != null) {
      children
        ..add(
          Positioned(
            top: 0.0,
            right: 0.0,
            child: Badge(
              color: color,
              value: value,
            ),
          ),
        );
    }

    return Container(
      width: size,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Stack(
        alignment: Alignment.center,
        children: children,
      ),
    );
  }
}
