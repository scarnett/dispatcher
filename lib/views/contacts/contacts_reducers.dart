import 'package:dispatcher/views/contacts/contacts_actions.dart';
import 'package:dispatcher/views/contacts/contacts_state.dart';
import 'package:redux/redux.dart';

final contactsReducer = combineReducers<ContactsState>([
  TypedReducer<ContactsState, SetContactsAction>(_contacts),
  TypedReducer<ContactsState, SetContactsLabelsAction>(_contactsLabels),
  TypedReducer<ContactsState, AddContactsLabelAction>(_contactsLabel),
  TypedReducer<ContactsState, SetActiveContactAction>(_activeContact),
  TypedReducer<ContactsState, ClearActiveContactAction>(_clearActiveContact),
  TypedReducer<ContactsState, SetContactsSearchingAction>(_searching),
]);

ContactsState _contacts(
  ContactsState state,
  SetContactsAction action,
) =>
    state.copyWith(
      contacts: action.contacts,
    );

ContactsState _contactsLabels(
  ContactsState state,
  SetContactsLabelsAction action,
) =>
    state.copyWith(
      contactsLabels: action.labels,
    );

ContactsState _contactsLabel(
  ContactsState state,
  AddContactsLabelAction action,
) {
  List<String> contactsLabels = state.contactsLabels;
  contactsLabels..add(action.contactsLabel);

  return state.copyWith(
    contactsLabels: contactsLabels,
  );
}

ContactsState _activeContact(
  ContactsState state,
  SetActiveContactAction action,
) =>
    state.copyWith(
      activeContact: action.identifier,
    );

ContactsState _clearActiveContact(
  ContactsState state,
  ClearActiveContactAction action,
) =>
    state.copyWith(
      activeContact: null,
    );

ContactsState _searching(
  ContactsState state,
  SetContactsSearchingAction action,
) =>
    state.copyWith(
      searching: action.searching,
    );
