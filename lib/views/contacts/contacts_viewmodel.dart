import 'package:contacts_service/contacts_service.dart';
import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/views/contacts/contacts_actions.dart';
import 'package:redux/redux.dart';
import 'package:dispatcher/state.dart';

class ContactsViewModel {
  final List<Contact> contacts;
  final List<String> contactsLabels;
  final String activeContact;
  final bool searching;
  final InviteCode inviteCode;
  final Contact Function(String identifier) getContact;
  final Contact Function() getActiveContact;
  final List<Contact> Function(List<Contact> contacts) setContacts;
  final List<String> Function(List<String> labels) setContactsLabels;
  final Function(String contactsLabel) addContactsLabel;
  final Function(String identifer) setActiveContact;
  final Function() clearActiveContact;
  final Function({bool searching}) toggleSearching;

  ContactsViewModel({
    this.contacts,
    this.contactsLabels,
    this.activeContact,
    this.searching,
    this.inviteCode,
    this.getContact,
    this.getActiveContact,
    this.setContacts,
    this.setContactsLabels,
    this.addContactsLabel,
    this.setActiveContact,
    this.clearActiveContact,
    this.toggleSearching,
  });

  static ContactsViewModel fromStore(
    Store<AppState> store,
  ) =>
      ContactsViewModel(
        contacts: store.state.contactsState.contacts,
        contactsLabels: store.state.contactsState.contactsLabels,
        activeContact: store.state.contactsState.activeContact,
        searching: store.state.contactsState.searching,
        inviteCode: store.state.deviceState.device.inviteCode,
        getContact: (identifier) => store.state.contactsState.contacts
            .firstWhere((contact) => contact.identifier == identifier),
        getActiveContact: () => store.state.contactsState.contacts.firstWhere(
            (contact) =>
                contact.identifier == store.state.contactsState.activeContact),
        setContacts: (contacts) => store.dispatch(
          SetContactsAction(contacts),
        ),
        setContactsLabels: (labels) => store.dispatch(
          SetContactsLabelsAction(labels),
        ),
        addContactsLabel: (contactsLabel) => store.dispatch(
          AddContactsLabelAction(contactsLabel),
        ),
        setActiveContact: (identifier) => store.dispatch(
          SetActiveContactAction(identifier),
        ),
        clearActiveContact: () => store.dispatch(
          ClearActiveContactAction(),
        ),
        toggleSearching: ({bool searching}) => store.dispatch(
          SetContactsSearchingAction((searching == null)
              ? !store.state.contactsState.searching
              : searching),
        ),
      );
}
