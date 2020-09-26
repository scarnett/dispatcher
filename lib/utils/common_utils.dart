import 'dart:math';

import 'package:flutter/material.dart';

abstract class Enum<T> {
  final T _value;
  const Enum(this._value);
  T get value => _value;
}

dynamic setValue(
  dynamic value, {
  dynamic def,
}) {
  if (value == null) {
    return def;
  }

  return value;
}

// @see https://github.com/flutter/flutter/issues/17862
List<Widget> filterNullWidgets(
  List<Widget> widgets,
) {
  if (widgets == null) {
    return null;
  }

  return widgets.where((child) => child != null).toList();
}

String toCamelCase(
  String str,
) {
  String s = str
      .replaceAllMapped(
          RegExp(
              r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
          (Match m) =>
              "${m[0][0].toUpperCase()}${m[0].substring(1).toLowerCase()}")
      .replaceAll(RegExp(r'(_|-|\s)+'), '');
  return s[0].toLowerCase() + s.substring(1);
}

String getRandomString({
  int length = 6,
  bool upperCase: true,
  bool lowerCase: false,
}) {
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String randomString = String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  if (upperCase) {
    return randomString.toUpperCase();
  } else if (lowerCase) {
    return randomString.toLowerCase();
  }

  return randomString;
}

String getRandomNumber({
  int length = 6,
}) {
  const _nums = '1234567890';
  Random _rnd = Random();

  String randomNumber = String.fromCharCodes(Iterable.generate(
      length, (_) => _nums.codeUnitAt(_rnd.nextInt(_nums.length))));

  return randomNumber;
}

void closeKeyboard(
  BuildContext context,
) {
  // Close the keyboard if it's open
  FocusScope.of(context).unfocus();
}

class Nullable<T> {
  T _value;

  Nullable(
    this._value,
  );

  T get value => _value;
}
