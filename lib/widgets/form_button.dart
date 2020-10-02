import 'package:dispatcher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final Color color;
  final Color disabledColor;
  final Color textColor;
  final bool textButton;

  FormButton({
    Key key,
    @required this.onPressed,
    @required this.text,
    this.color,
    this.disabledColor,
    this.textColor,
    this.textButton = false,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      FlatButton(
        color: (color == null) ? AppTheme.primary : color,
        disabledTextColor:
            textButton ? AppTheme.hint : Colors.white.withOpacity(0.5),
        disabledColor: (disabledColor == null)
            ? textButton
                ? Colors.white.withOpacity(0.5)
                : AppTheme.primary.withOpacity(0.5)
            : disabledColor,
        textColor: textColor,
        child: Text(text),
        onPressed: onPressed,
      );
}
