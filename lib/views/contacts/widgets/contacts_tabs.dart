import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/contacts/contacts_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class ContactsTabs extends StatelessWidget implements PreferredSizeWidget {
  // The height of the TabBar
  final double height;

  // The AppBar tab controller
  final TabController tabController;

  // The AppBar tab labels
  final List<String> tabLabels;

  const ContactsTabs({
    Key key,
    @required this.height,
    @required this.tabController,
    @required this.tabLabels,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> tabs = <Widget>[];

    for (String label in tabLabels) {
      tabs.add(_buildTab(label));
    }

    return StoreConnector<AppState, ContactsViewModel>(
      converter: (store) => ContactsViewModel.fromStore(store),
      builder: (_, viewModel) => Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.background,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: (viewModel.contacts.length == 0)
            ? Container()
            : Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: TabBar(
                        controller: tabController,
                        isScrollable: true,
                        tabs: tabs,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Builds a tab widget.
  Widget _buildTab(
    String text,
  ) =>
      Tab(
        icon: Container(
          padding: const EdgeInsets.only(
            left: 10.0,
            right: 10.0,
          ),
          child: Text(text),
        ),
      );

  @override
  Size get preferredSize => Size.fromHeight(height);
}
