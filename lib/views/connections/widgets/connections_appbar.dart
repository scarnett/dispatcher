import 'package:dispatcher/localization.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/views/contacts/contacts_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class ConnectionsAppBar extends StatefulWidget implements PreferredSizeWidget {
  // The height of the AppBar
  final double height;

  ConnectionsAppBar({
    Key key,
    @required this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectionsAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _ConnectionsAppBarState extends State<ConnectionsAppBar> {
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
              child: _buildTitle(),
            ),
          ),
        ),
      );

  /// Builds the AppBar title text.
  Widget _buildTitle() => Container(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 30.0,
        ),
        child: Text(
          AppLocalizations.of(context).connections,
          style: Theme.of(context).textTheme.headline3,
        ),
      );
}
