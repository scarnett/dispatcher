import 'package:contacts_service/contacts_service.dart';
import 'package:dispatcher/views/contacts/bloc/contacts.dart';
import 'package:dispatcher/views/contacts/models/search.dart';

/// Filters the contact list by label
List<Contact> getFilteredContacts(
  ContactsState state,
  int activeContactTabIndex, {
  Search search,
}) {
  Search _search = (search == null) ? state.search : search;
  if ((activeContactTabIndex == null) || (activeContactTabIndex == 0)) {
    return filterByCriteria(_search, state.contacts);
  }

  if (state.contacts != null) {
    List<Contact> filteredContacts =
        filterByTabIndex(state, activeContactTabIndex);
    return filterByCriteria(_search, filteredContacts);
  }

  return filterByCriteria(_search, state.contacts);
}

/// Filters the contact list by tab index
List<Contact> filterByTabIndex(
  ContactsState state,
  int activeContactTabIndex,
) {
  List<Contact> filteredContacts = <Contact>[];

  for (Contact contact in state.contacts) {
    String activeTabLabel =
        (state.contactLabels[activeContactTabIndex]).toLowerCase();

    if (activeTabLabel == 'all') {
      filteredContacts..add(contact);
    } else {
      List<Item> labels = contact.emails
          .where((email) => (email.label.toLowerCase() == activeTabLabel))
          .toList();

      if (labels.length > 0) {
        filteredContacts..add(contact);
      }
    }
  }

  return filteredContacts;
}

/// Filters the contact list by search criteria
List<Contact> filterByCriteria(
  Search search,
  List<Contact> contacts,
) {
  if ((search.value != null) && (search.value.length > 1)) {
    return contacts
        .where((contact) => contact.displayName
            .toLowerCase()
            .contains(search.value.toLowerCase()))
        .toList();
  }

  return contacts;
}
