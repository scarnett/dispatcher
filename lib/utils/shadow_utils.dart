import 'package:flutter/material.dart';

/// Generates a common box shadow
List<BoxShadow> commonBoxShadow({
  color: Colors.black26,
  blurRadius: 1.0,
}) =>
    [
      BoxShadow(
        color: color,
        blurRadius: blurRadius,
        offset: const Offset(0.0, 1.0),
      ),
    ];
