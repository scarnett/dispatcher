import 'package:dispatcher/model.dart';
import 'package:dispatcher/theme.dart';
import 'package:flutter/material.dart';

SnackBar builSnackBar(
  Message message,
) {
  return SnackBar(
    backgroundColor: _getBackgroundColor(message),
    content: Text(
      message.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14.0,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w300,
      ),
    ),
    duration: Duration(seconds: message.duration),
  );
}

Color _getBackgroundColor(
  Message message,
) {
  switch (message.type) {
    case MessageType.SUCCESS:
      return AppTheme.success;

    case MessageType.WARNING:
      return AppTheme.warning;

    case MessageType.ERROR:
      return AppTheme.error;

    case MessageType.INFO:
    default:
      return AppTheme.info;
  }
}
