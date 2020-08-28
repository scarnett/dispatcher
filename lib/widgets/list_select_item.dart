import 'package:dispatcher/theme.dart';
import 'package:flutter/material.dart';

class ListSelectItem extends StatefulWidget {
  final String title;
  final double fontSize;
  final IconData icon;
  final double iconSize;
  final bool borderTop;
  final bool borderBottom;
  final bool disabled;
  final GestureTapCallback onTap;

  ListSelectItem({
    @required this.title,
    @required this.icon,
    this.fontSize: 16.0,
    this.iconSize: 20.0,
    this.borderTop = false,
    this.borderBottom = true,
    this.disabled: false,
    this.onTap,
  });

  @override
  _ListSelectItemState createState() => _ListSelectItemState();
}

class _ListSelectItemState extends State<ListSelectItem> {
  @override
  Widget build(
    BuildContext context,
  ) {
    if (widget.disabled) {
      return _getItem(disabled: widget.disabled);
    }

    return InkWell(
      onTap: widget.onTap,
      child: _getItem(),
    );
  }

  Widget _getItem({
    bool disabled = false,
  }) =>
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.border,
              width: 1.0,
              style: widget.borderBottom ? BorderStyle.solid : BorderStyle.none,
            ),
            top: BorderSide(
              color: AppTheme.border,
              width: 1.0,
              style: widget.borderTop ? BorderStyle.solid : BorderStyle.none,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 30.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    widget.icon,
                    color: disabled ? AppTheme.hint : AppTheme.primary,
                    size: widget.iconSize,
                  ),
                ),
              ),
              Text(
                widget.title,
                style: TextStyle(
                  color: disabled ? AppTheme.hint : AppTheme.text,
                  fontSize: widget.fontSize,
                ),
              ),
            ],
          ),
        ),
      );
}
