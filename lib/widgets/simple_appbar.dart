import 'package:dispatcher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleAppBar extends StatefulWidget implements PreferredSizeWidget {
  // The height of the AppBar
  final double height;

  final bool automaticallyImplyLeading;

  final bool showBackButton;

  // The AppBar title
  final String title;

  SimpleAppBar({
    Key key,
    this.height,
    this.automaticallyImplyLeading = false,
    this.showBackButton = false,
    this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SimpleAppBarState();

  @override
  Size get preferredSize => Size.fromHeight((height == null) ? 50.0 : height);
}

class _SimpleAppBarState extends State<SimpleAppBar> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      AppBar(
        backgroundColor: AppTheme.background,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        leading: (widget.showBackButton)
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, false),
              )
            : null,
        flexibleSpace: (widget.title == null)
            ? Container()
            : Container(
                width: MediaQuery.of(context).copyWith().size.width,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTitle(),
                    ],
                  ),
                ),
              ),
      );

  /// Builds the AppBar title text.
  Widget _buildTitle() => Expanded(
        child: Container(
          padding: EdgeInsets.only(
            left: widget.automaticallyImplyLeading ? 60.0 : 20.0,
            right: 20.0,
            top: 30.0,
          ),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
      );
}
