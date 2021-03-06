import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoomAppBar extends StatefulWidget implements PreferredSizeWidget {
  // The height of the AppBar
  final double height;

  final String title;

  RoomAppBar({
    Key key,
    @required this.height,
    @required this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _RoomAppBarState extends State<RoomAppBar> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      AppBar(
        title: _buildTitle(),
        elevation: 4.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      );

  /// Builds the AppBar title text.
  Widget _buildTitle() => Container(
        child: Text(
          widget.title,
          style: Theme.of(context).textTheme.headline5,
        ),
      );
}
