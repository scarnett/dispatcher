import 'package:contacts_service/contacts_service.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/text_utils.dart';
import 'package:dispatcher/views/contacts/contacts_viewmodel.dart';
import 'package:dispatcher/views/contacts/contact/widgets/contact_avatar.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:share/share.dart';

class ContactView extends StatefulWidget {
  ContactView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, ContactsViewModel>(
        converter: (store) => ContactsViewModel.fromStore(store),
        builder: (_, viewModel) => WillPopScope(
          onWillPop: () => _willPopCallback(viewModel),
          child: Scaffold(
            appBar: SimpleAppBar(
              height: 100.0,
            ),
            body: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    _buildContact(viewModel),
                    _buildInviteCodeText(viewModel),
                    _buildInviteButton(viewModel),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<bool> _willPopCallback(
    ContactsViewModel viewModel,
  ) async {
    viewModel.clearActiveContact();
    return true;
  }

  Widget _buildContact(
    ContactsViewModel viewModel,
  ) {
    Contact contact = viewModel.getActiveContact();
    List<Widget> children = <Widget>[];
    children
      ..add(
        ContactAvatar(
          contact: contact,
          avatarRadius: 40.0,
        ),
      );

    children
      ..add(
        Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
          ),
          child: Text(
            removeEmojis(contact.displayName),
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
      );

    if (contact.emails.length > 0) {
      children
        ..add(
          Text(
            contact.emails.first.value,
            style: Theme.of(context).textTheme.subtitle2,
          ),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildInviteCodeText(
    ContactsViewModel viewModel,
  ) =>
      Padding(
        padding: const EdgeInsets.only(
          bottom: 20.0,
          top: 20.0,
        ),
        child: Column(
          children: <Widget>[
            Text(
              viewModel.inviteCode.code,
              style: Theme.of(context).textTheme.headline6.copyWith(
                    color: AppTheme.accent,
                  ),
            ),
            Text(
              AppLocalizations.of(context).yourInviteCode,
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
      );

  Widget _buildInviteButton(
    ContactsViewModel viewModel,
  ) =>
      FlatButton(
        color: AppTheme.primary,
        child: Text(AppLocalizations.of(context).sendInvite),
        onPressed: () => Share.share(
          AppLocalizations.of(context).inviteCodeText(
            AppLocalizations.appTitle,
            viewModel.inviteCode.code,
          ),
        ),
      );
}
