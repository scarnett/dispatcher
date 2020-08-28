import 'package:contacts_service/contacts_service.dart';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/text_utils.dart';
import 'package:dispatcher/views/contacts/widgets/contacts_appbar.dart';
import 'package:dispatcher/views/contacts/contacts_viewmodel.dart';
import 'package:dispatcher/views/contacts/contact/widgets/contact_avatar.dart';
import 'package:dispatcher/widgets/none_found.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class ContactsView extends StatefulWidget {
  ContactsView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // List of contact labels
  List<String> _contactsLabels = <String>[];

  // List of filtered contacts
  List<Contact> _filteredContacts = <Contact>[];

  // The contact list tab controller
  TabController _contactTabController;

  // The scroll controller for the ListView
  ScrollController _contactListViewController;

  // The text controller for the search field
  TextEditingController _searchTextController;

  // Search contacts criteria
  String _searchCriteria;

  // The index of the active contact tab
  int _activeContactTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Setup the ListView controller
    _contactListViewController = ScrollController();

    // Setup the Search text controller
    _searchTextController = TextEditingController();

    // Setup the tab controller
    _contactTabController = TabController(
      vsync: this,
      length: 0,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, ContactsViewModel>(
        converter: (store) => ContactsViewModel.fromStore(store),
        onInitialBuild: (viewModel) {
          _filteredContacts = _getFilteredContacts(viewModel);
          _searchTextController
              .addListener(() => _filterContactsListener(viewModel));

          updateContactsLabels(viewModel);
        },
        onWillChange: (_, viewModel) => updateContactsLabels(viewModel),
        builder: (_, viewModel) => Scaffold(
          appBar: ContactsAppBar(
            height: 140,
            tabController: _contactTabController,
            tabLabels: _contactsLabels..sort(),
          ),
          body: Column(
            children: <Widget>[
              _buildSearch(viewModel),
              _buildContacts(viewModel),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _contactTabController.dispose();
    _contactListViewController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  /// Updates the contacts labels list.
  updateContactsLabels(
    ContactsViewModel viewModel,
  ) =>
      setState(() {
        _contactsLabels = viewModel.contactsLabels;

        // Setup the tab controller
        _contactTabController = TabController(
          vsync: this,
          length: _contactsLabels.length,
        );

        _contactTabController.addListener(() => _handleTabSelection(viewModel));
      });

  /// Listens to the search criteria and filters the contacts list.
  _filterContactsListener(
    ContactsViewModel viewModel,
  ) =>
      setState(() {
        _searchCriteria = _searchTextController.text;
        _filteredContacts = _getFilteredContacts(viewModel);
      });

  /// Handles a tap on one of the tabs.
  void _handleTabSelection(
    ContactsViewModel viewModel,
  ) {
    if (!_contactTabController.indexIsChanging) {
      setState(() {
        _activeContactTabIndex = _contactTabController.index;
        _filteredContacts = _getFilteredContacts(viewModel);

        // Scrolls the list back to the top
        _contactListViewController
            .jumpTo(_contactListViewController.position.minScrollExtent);
      });
    }
  }

  /// Builds the search text field widget.
  Widget _buildSearch(
    ContactsViewModel viewModel,
  ) {
    if (viewModel.searching) {
      return Padding(
        padding: const EdgeInsets.only(
          bottom: 2.0,
          left: 20.0,
          right: 20.0,
          top: 10.0,
        ),
        child: TextFormField(
          autofocus: true,
          controller: _searchTextController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).search,
            suffixIcon: (_searchCriteria != '')
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.hint,
                    ),
                    onPressed: () => _searchTextController.clear(),
                  )
                : null,
          ),
        ),
      );
    }

    return Container();
  }

  /// Builds a list of contact widgets.
  Widget _buildContacts(
    ContactsViewModel viewModel,
  ) {
    if (_filteredContacts == null) {
      return Spinner();
    }

    if (_filteredContacts.length == 0) {
      return NoneFound(
        message: AppLocalizations.of(context).contactsNone,
      );
    }

    return Flexible(
      child: ListView.builder(
        controller: _contactListViewController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _filteredContacts?.length ?? 0,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          Contact contact = _filteredContacts?.elementAt(index);

          return InkWell(
            onTap: () => _setActiveContact(viewModel, contact),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ContactAvatar(contact: contact),
                  ),
                  _buildContact(contact),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a contact widget.
  Widget _buildContact(
    Contact contact,
  ) {
    List<Widget> children = <Widget>[];
    children
      ..add(
        Text(
          removeEmojis(contact.displayName),
          style: Theme.of(context).textTheme.headline6,
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

    return Container(
      child: Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  /// Filters the contact list by label
  List<Contact> _getFilteredContacts(
    ContactsViewModel viewModel,
  ) {
    if (_activeContactTabIndex == 0) {
      return _filterByCriteria(viewModel.contacts);
    }

    List<Contact> filteredContacts = <Contact>[];

    for (Contact contact in viewModel.contacts) {
      String activeTabLabel =
          (_contactsLabels[_activeContactTabIndex]).toLowerCase();

      List<Item> labels = contact.emails
          .where((email) => (email.label.toLowerCase() == activeTabLabel))
          .toList();

      if (labels.length > 0) {
        filteredContacts..add(contact);
      }
    }

    return _filterByCriteria(filteredContacts);
  }

  /// Filters the contact list by search criteria
  List<Contact> _filterByCriteria(
    List<Contact> contacts,
  ) {
    if ((_searchCriteria != null) && (_searchCriteria.length > 1)) {
      return contacts
          .where((contact) => contact.displayName
              .toLowerCase()
              .contains(_searchCriteria.toLowerCase()))
          .toList();
    }

    return contacts;
  }

  /// Sets the active contact and navigates to the contact details
  void _setActiveContact(
    ContactsViewModel viewModel,
    Contact contact,
  ) {
    viewModel.setActiveContact(contact.identifier);
    viewModel.toggleSearching(searching: false);

    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.contact));
  }
}
