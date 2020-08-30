import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

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
  ) =>
      StoreConnector<AppState, AppViewModel>(
        converter: (store) => AppViewModel.fromStore(store),
        builder: (_, viewModel) {
          List<Widget> items = List.generate(
            widget.items.length,
            (int index) => _buildTabItem(
              viewModel: viewModel,
              item: widget.items[index],
              index: index,
              onPressed: (index) => _updateIndex(index),
            ),
          );

          items..insert(items.length >> 1, Container());

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
        },
      );

  void _updateIndex(
    int index,
  ) {
    widget.onTabSelected(index);
  }

  Widget _buildTabItem({
    AppViewModel viewModel,
    BottomNavBarItem item,
    int index,
    ValueChanged<int> onPressed,
  }) =>
      Material(
        type: MaterialType.transparency,
        child: _buildButton(
          viewModel,
          item,
          index,
          onPressed,
        ),
      );

  Widget _buildButton(
    AppViewModel viewModel,
    BottomNavBarItem item,
    int index,
    ValueChanged<int> onPressed,
  ) {
    Color color = (viewModel.selectedTabIndex == index)
        ? widget.selectedColor
        : widget.color;

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
          child: Icon(
            item.iconData,
            color: color,
            size: widget.verbose ? widget.verboseIconSize : widget.iconSize,
          ),
        ),
      ),
    );
  }
}
