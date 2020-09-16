import 'package:dispatcher/theme.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final Key key;
  final String label;
  final bool autovalidate;
  final String initialValue;
  final String hintText;
  final String errorText;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final Widget suffixIcon;
  final int maxLines;
  final bool autofocus;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> onChanged;

  CustomTextField({
    this.key,
    this.label,
    this.autovalidate = false,
    this.initialValue,
    this.hintText,
    this.errorText,
    this.color: Colors.black,
    this.icon,
    this.iconColor,
    this.suffixIcon,
    this.maxLines: 1,
    this.autofocus: false,
    this.keyboardType: TextInputType.text,
    this.obscureText: false,
    this.textCapitalization: TextCapitalization.words,
    this.controller,
    this.validator,
    this.onSaved,
    this.onChanged,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      TextFormField(
        key: widget.key,
        controller: widget.controller,
        autovalidate: widget.autovalidate,
        initialValue: widget.initialValue,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLines: widget.maxLines,
        autofocus: widget.autofocus,
        textCapitalization: widget.textCapitalization,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        style: TextStyle(
          color: widget.color,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          errorText: widget.errorText,
          contentPadding: const EdgeInsets.only(
            left: 0.0,
            right: 20.0,
            top: 15.0,
          ),
          prefixIcon: (widget.icon == null)
              ? null
              : Icon(
                  widget.icon,
                  color: (widget.iconColor == null)
                      ? AppTheme.hint
                      : widget.iconColor,
                ),
          suffixIcon: widget.suffixIcon,
        ),
      );
}
