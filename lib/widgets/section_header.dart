import 'package:dispatcher/theme.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatefulWidget {
  final String text;
  final bool borderTop;
  final bool borderBottom;

  SectionHeader({
    @required this.text,
    this.borderTop = false,
    this.borderBottom = true,
  });

  @override
  _SectionHeaderState createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            bottom: BorderSide(
              color: AppTheme.border,
              width: widget.borderBottom ? 1.0 : 0.0,
            ),
            top: BorderSide(
              color: AppTheme.border,
              width: widget.borderTop ? 1.0 : 0.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        child: _buildText(),
      );

  Widget _buildText() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            widget.text,
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      );
}
