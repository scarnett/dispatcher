import 'package:dispatcher/localization.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/contacts/contacts_viewmodel.dart';
import 'package:dispatcher/views/contacts/widgets/contacts_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class ContactsAppBar extends StatefulWidget implements PreferredSizeWidget {
  // The height of the AppBar
  final double height;

  // The AppBar tab controller
  final TabController tabController;

  // The AppBar tab labels
  final List<String> tabLabels;

  ContactsAppBar({
    Key key,
    @required this.height,
    @required this.tabController,
    @required this.tabLabels,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactsAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _ContactsAppBarState extends State<ContactsAppBar> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          width: MediaQuery.of(context).copyWith().size.width,
          child: StoreConnector<AppState, ContactsViewModel>(
            converter: (store) => ContactsViewModel.fromStore(store),
            builder: (_, viewModel) => Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTitle(),
                  _buildSearchIcon(viewModel),
                ],
              ),
            ),
          ),
        ),
        bottom: ContactsTabs(
          height: 40.0,
          tabController: widget.tabController,
          tabLabels: widget.tabLabels,
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
    ContactsViewModel viewModel,
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
              color: viewModel.searching ? AppTheme.primary : AppTheme.hint,
            ),
            onPressed: (viewModel.contacts.length == 0)
                ? null
                : () => viewModel.toggleSearching(),
          ),
        ),
      );
}
