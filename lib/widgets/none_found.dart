import 'package:dispatcher/localization.dart';
import 'package:dispatcher/theme.dart';
import 'package:flutter/material.dart';

class NoneFound extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final double size;
  final double padding;

  NoneFound({
    this.icon: Icons.sentiment_dissatisfied,
    this.title,
    this.message,
    this.size: 70.0,
    this.padding: 20.0,
  });

  @override
  _NoneFoundState createState() => _NoneFoundState();
}

class _NoneFoundState extends State<NoneFound> with TickerProviderStateMixin {
  @override
  Widget build(
    BuildContext context,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 10.0,
            ),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: widget.size,
              ),
            ),
          ),
          (widget.title == null)
              ? Container()
              : Text(
                  (widget.title != null)
                      ? widget.title
                      : AppLocalizations.of(context).bummer,
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 28.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
          Padding(
            padding: EdgeInsets.only(
              top: 4.0,
              bottom: widget.padding,
            ),
            child: (widget.message == null)
                ? Container()
                : Text(
                    (widget.message != null)
                        ? widget.message
                        : AppLocalizations.of(context).bummerText,
                    style: const TextStyle(
                      color: AppTheme.hint,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      );
}
