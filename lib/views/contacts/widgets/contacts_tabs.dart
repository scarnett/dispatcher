import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/contacts/bloc/bloc.dart';
import 'package:dispatcher/views/contacts/bloc/contacts_bloc.dart';
import 'package:dispatcher/views/contacts/bloc/contacts_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsTabs extends StatelessWidget implements PreferredSizeWidget {
  // The height of the TabBar
  final double height;

  // The AppBar tab controller
  final TabController tabController;

  ContactsTabs({
    Key key,
    @required this.height,
    @required this.tabController,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocBuilder<ContactsBloc, ContactsState>(
        builder: (
          BuildContext context,
          ContactsState state,
        ) =>
            Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.background,
                width: 1.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
          child: Align(
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
                    tabs: _buildTabs(state),
                    onTap: (int index) => context
                        .bloc<ContactsBloc>()
                        .add(ActiveContactTab(index)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  /// Builds the tabs
  List<Widget> _buildTabs(
    ContactsState state,
  ) {
    List<Widget> tabs = <Widget>[];

    if (state.contactLabels != null) {
      for (String label in state.contactLabels) {
        tabs.add(_buildTab(label));
      }
    }

    return tabs;
  }

  /// Builds a tab
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
