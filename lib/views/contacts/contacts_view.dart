import 'package:contacts_service/contacts_service.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/text_utils.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/contacts/bloc/contacts_bloc.dart';
import 'package:dispatcher/views/contacts/bloc/contacts_events.dart';
import 'package:dispatcher/views/contacts/bloc/contacts_state.dart';
import 'package:dispatcher/views/contacts/contact/contact_view.dart';
import 'package:dispatcher/views/contacts/contacts_enums.dart';
import 'package:dispatcher/views/contacts/widgets/contacts_appbar.dart';
import 'package:dispatcher/views/contacts/contact/widgets/contact_avatar.dart';
import 'package:dispatcher/widgets/none_found.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supercharged/supercharged.dart';

class ContactsView extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ContactsView());

  const ContactsView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocProvider<ContactsBloc>(
        create: (BuildContext context) => ContactsBloc()
          ..add(
            FetchInviteCodeData(context.bloc<AuthBloc>().state.firebaseUser),
          )
          ..add(
            FetchContactsData(context),
          ),
        child: ContactsPageView(),
      );
}

class ContactsPageView extends StatefulWidget {
  ContactsPageView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactsPageViewState();
}

class _ContactsPageViewState extends State<ContactsPageView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PageController _pageController;

  TabController _tabController;

  // The scroll controller for the ListView
  ScrollController _contactListViewController;

  // The text controller for the search field
  TextEditingController _searchTextController;

  @override
  void initState() {
    // Setup the PageView controller
    _pageController = PageController(
      initialPage: 0,
    )..addListener(() {
        // Clear the active contact if the user navigates back to the contact list
        if (_pageController.page.round() == 0) {
          context.bloc<ContactsBloc>().add(ClearActiveContact());
        }
      });

    // Setup the TabBar controller
    _tabController = TabController(
      vsync: this,
      length: 0,
    );

    // Setup the ListView controller
    _contactListViewController = ScrollController();

    // Setup the Search text controller
    _searchTextController = TextEditingController();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController?.dispose();
    _tabController?.dispose();
    _contactListViewController?.dispose();
    _searchTextController?.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocListener<ContactsBloc, ContactsState>(
        listener: (
          BuildContext context,
          ContactsState state,
        ) {
          _updateContactsLabels(state);

          if (!state.searching) {
            _searchTextController.clear();
          }
        },
        child: BlocBuilder<ContactsBloc, ContactsState>(
          builder: (
            BuildContext context,
            ContactsState state,
          ) =>
              WillPopScope(
            onWillPop: () => _willPopCallback(state),
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (
                BuildContext context,
                Widget _,
              ) =>
                  PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: _getPages(state),
              ),
            ),
          ),
        ),
      );

  /// Handles the android back button
  Future<bool> _willPopCallback(
    ContactsState state,
  ) {
    if (_pageController.page.round() > 0) {
      moveToPage(_pageController, ContactsMode.CONTACTS);
      return Future.value(false);
    }

    return Future.value(true);
  }

  /// Builds the search text field widget.
  Widget _buildSearch(
    ContactsState state,
  ) {
    if (state.searching) {
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
          onChanged: (criteria) =>
              context.bloc<ContactsBloc>().add(SearchChanged(criteria)),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).search,
            suffixIcon: (state.search.value != '')
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.hint,
                    ),
                    onPressed: _tapClearSearch,
                  )
                : null,
          ),
        ),
      );
    }

    return Container();
  }

  /// Builds the PageView pages
  List<Widget> _getPages(
    ContactsState state,
  ) {
    List<Widget> pages = [];
    pages..add(_getContacts(state))..add(ContactView());
    return pages;
  }

  /// Builds the content
  Widget _getContacts(
    ContactsState state,
  ) {
    List<Widget> children = <Widget>[]..add(_buildContacts(state));

    if (state.contacts == null) {
      children.add(
        Spinner(
          message: AppLocalizations.of(context).contactsLoading,
        ),
      );
    }

    return Container(
      child: Stack(
        children: filterNullWidgets(children),
      ),
    );
  }

  Widget _buildContacts(
    ContactsState state,
  ) =>
      Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: ContactsAppBar(
          height: 140,
          tabController: _tabController,
        ),
        body: Column(
          children: <Widget>[
            _buildSearch(state),
            _buildContactList(state),
          ],
        ),
      );

  /// Builds a list of contact widgets.
  Widget _buildContactList(
    ContactsState state,
  ) {
    List<Contact> _contacts = (state.filteredContacts != null)
        ? state.filteredContacts
        : state.contacts;

    if ((_contacts == null) || (_contacts.length == 0)) {
      return NoneFound(
        message: AppLocalizations.of(context).contactsNone,
      );
    }

    return Flexible(
      child: ListView.builder(
        controller: _contactListViewController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _contacts?.length ?? 0,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          Contact contact = _contacts?.elementAt(index);

          return InkWell(
            onTap: () => _tapContact(contact),
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

  /// Handles the 'contact' tap
  void _tapContact(
    Contact contact,
  ) {
    context.bloc<ContactsBloc>().add(ActiveContact(contact.identifier));
    moveToPage(_pageController, ContactsMode.CONTACT);
  }

  /// Handles the 'clear search' tap
  void _tapClearSearch() {
    _searchTextController.clear();
    context.bloc<ContactsBloc>().add(const ClearSearch());
  }

  void _updateContactsLabels(
    ContactsState state,
  ) {
    setState(() {
      // Setup the tab controller
      _tabController = TabController(
        vsync: this,
        length: (state.contactLabels == null) ? 0 : state.contactLabels.length,
      );

      _tabController.animateTo(state.activeContactTabIndex);
    });
  }

  void moveToPage(
    PageController pageController,
    ContactsMode contactsMode, {
    int pageAnimationDuration: 150,
    Cubic pageAnimationCurve: Curves.easeInOut,
  }) {
    pageController.animateToPage(
      contactsMode.pageIndex,
      duration: pageAnimationDuration.milliseconds,
      curve: pageAnimationCurve,
    );
  }
}
