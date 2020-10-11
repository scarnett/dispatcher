import 'package:contacts_service/contacts_service.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/text_utils.dart';
import 'package:dispatcher/views/contacts/bloc/bloc.dart';
import 'package:dispatcher/views/contacts/contact/widgets/contact_avatar.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';

class ContactView extends StatefulWidget {
  final PageController pageController;

  ContactView({
    Key key,
    this.pageController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocBuilder<ContactsBloc, ContactsState>(
        builder: (
          BuildContext context,
          ContactsState state,
        ) =>
            Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: true,
          appBar: SimpleAppBar(showLeading: true),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      _buildContact(state),
                      _buildInviteCodeText(state),
                      _buildInviteButton(state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildContact(
    ContactsState state,
  ) {
    assert(state.contacts != null);

    Contact contact = state.contacts.firstWhere(
        (contact) => contact.identifier == state.activeContact,
        orElse: () => null);

    if (contact == null) {
      return Container();
    }

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
    ContactsState state,
  ) =>
      Padding(
        padding: const EdgeInsets.only(
          bottom: 20.0,
          top: 20.0,
        ),
        child: Column(
          children: <Widget>[
            Text(
              state.inviteCode.code,
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
    ContactsState state,
  ) =>
      FormButton(
        text: AppLocalizations.of(context).sendInvite,
        onPressed: () => Share.share(
          AppLocalizations.of(context).inviteCodeText(
            AppLocalizations.appTitle,
            state.inviteCode.code,
          ),
        ),
      );
}
