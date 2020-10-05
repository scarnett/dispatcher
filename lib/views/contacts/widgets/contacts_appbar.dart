import 'package:dispatcher/localization.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/contacts/bloc/bloc.dart';
import 'package:dispatcher/views/contacts/bloc/contacts_bloc.dart';
import 'package:dispatcher/views/contacts/bloc/contacts_state.dart';
import 'package:dispatcher/views/contacts/widgets/contacts_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsAppBar extends StatefulWidget implements PreferredSizeWidget {
  // The contact list tab controller
  final TabController tabController;

  // The height of the AppBar
  final double height;

  ContactsAppBar({
    Key key,
    @required this.tabController,
    @required this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactsAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _ContactsAppBarState extends State<ContactsAppBar>
    with TickerProviderStateMixin {
  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocBuilder<ContactsBloc, ContactsState>(
        builder: (
          BuildContext context,
          ContactsState state,
        ) =>
            AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            width: MediaQuery.of(context).copyWith().size.width,
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTitle(),
                  _buildSearchIcon(state),
                ],
              ),
            ),
          ),
          bottom: ContactsTabs(
            height: 40.0,
            tabController: widget.tabController,
          ),
        ),
      );

  /// Builds the AppBar title text.
  Widget _buildTitle() => Expanded(
        child: Container(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 30.0,
          ),
          child: Text(
            AppLocalizations.of(context).contacts,
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
      );

  /// Builds the search icon.
  Widget _buildSearchIcon(
    ContactsState state,
  ) =>
      Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          top: 20.0,
        ),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: IconButton(
            icon: Icon(
              Icons.search,
              color: state.searching ? AppTheme.primary : AppTheme.hint,
            ),
            onPressed: (state.contacts == null) || (state.contacts.length == 0)
                ? null
                : () => context
                    .bloc<ContactsBloc>()
                    .add(Searching(!state.searching)),
          ),
        ),
      );
}
