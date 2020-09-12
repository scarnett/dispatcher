import 'package:dispatcher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final Color color;
  final Color disabledColor;
  final Color textColor;

  FormButton({
    Key key,
    @required this.onPressed,
    @required this.text,
    this.color,
    this.disabledColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      FlatButton(
        color: (color == null) ? AppTheme.primary : color,
        disabledColor: (disabledColor == null) ? AppTheme.hint : disabledColor,
        textColor: textColor,
        child: Text(text),
        onPressed: onPressed,
      );
}
