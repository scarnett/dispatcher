import 'package:contacts_service/contacts_service.dart';

class SetContactsAction {
  final List<Contact> contacts;

  SetContactsAction(this.contacts);

  @override
  String toString() => 'SetContactsAction{contacts: $contacts}';
}

class SetContactsLabelsAction {
  final List<String> labels;

  SetContactsLabelsAction(this.labels);

  @override
  String toString() => 'SetContactsLabelsAction{labels: $labels}';
}

class AddContactsLabelAction {
  final String contactsLabel;

  AddContactsLabelAction(this.contactsLabel);

  @override
  String toString() => 'AddContactsLabelAction{contactsLabel: $contactsLabel}';
}

class SetActiveContactAction {
  final String identifier;

  SetActiveContactAction(this.identifier);

  @override
  String toString() => 'SetActiveContactAction{identifier: $identifier}';
}

class ClearActiveContactAction {
  ClearActiveContactAction();

  @override
  String toString() => 'ClearActiveContactAction{}';
}

class SetContactsSearchingAction {
  final bool searching;

  SetContactsSearchingAction(this.searching);

  @override
  String toString() => 'SetContactsSearchingAction{searching: $searching}';
}
