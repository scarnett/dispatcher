import 'package:dispatcher/theme.dart';
import 'package:flutter/material.dart';

class BottomNavBarItem {
  IconData iconData;
  String text;
  bool disabled;

  BottomNavBarItem({
    this.iconData,
    this.text,
    this.disabled: false,
  });
}

class BottomNavBar extends StatefulWidget {
  final List<BottomNavBarItem> items;
  final double height;
  final double verboseHeight;
  final double iconSize;
  final double verboseIconSize;
  final Color color;
  final int selectedIndex;
  final Color selectedColor;
  final ValueChanged<int> onTabSelected;
  final bool verbose;

  BottomNavBar({
    this.items,
    this.height: 60.0,
    this.verboseHeight: 60.0,
    this.iconSize: 24.0,
    this.verboseIconSize: 28.0,
    this.color,
    this.selectedIndex: 0,
    this.selectedColor: AppTheme.accent,
    this.onTabSelected,
    this.verbose: false,
  }) {
    assert((this.items.length == 2) || (this.items.length == 4));
  }

  @override
  State<StatefulWidget> createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> items = List.generate(
      widget.items.length,
      (int index) => _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: (index) => _updateIndex(index),
      ),
    );

    // Inserts an empty container in the center on the item list. This
    // gives us room to position the circlular menu into its place.
    items
      ..insert(
        items.length >> 1,
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
          ),
          child: Container(),
        ),
      );

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(
            color: AppTheme.border.withOpacity(0.5),
          ),
        ),
      ),
      alignment: Alignment.topCenter,
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
    );
  }

  void _updateIndex(
    int index,
  ) {
    widget.onTabSelected(index);
  }

  Widget _buildTabItem({
    BottomNavBarItem item,
    int index,
    ValueChanged<int> onPressed,
  }) =>
      Material(
        type: MaterialType.transparency,
        child: _buildButton(
          item,
          index,
          onPressed,
        ),
      );

  Widget _buildButton(
    BottomNavBarItem item,
    int index,
    ValueChanged<int> onPressed,
  ) {
    Color color =
        (widget.selectedIndex == index) ? widget.selectedColor : widget.color;

    if (widget.verbose) {
      return InkWell(
        highlightColor: Colors.transparent,
        onTap: item.disabled ? null : () => onPressed(index),
        child: Opacity(
          opacity: item.disabled ? 0.3 : 1.0,
          child: Container(
            constraints: BoxConstraints.tight(Size(60.0, 60.0)),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  item.iconData,
                  color: color,
                  size:
                      widget.verbose ? widget.verboseIconSize : widget.iconSize,
                ),
                (widget.verbose && (item.text != null))
                    ? Text(
                        item.text,
                        style: TextStyle(color: color),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      customBorder: CircleBorder(),
      onTap: item.disabled ? null : () => onPressed(index),
      splashColor: AppTheme.hint,
      child: Tooltip(
        message: item.disabled || widget.verbose ? null : item.text,
        child: Opacity(
          opacity: item.disabled ? 0.3 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              item.iconData,
              color: color,
              size: widget.verbose ? widget.verboseIconSize : widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
