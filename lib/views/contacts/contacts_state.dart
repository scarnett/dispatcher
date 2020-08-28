import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class ContactsState {
  final List<Contact> contacts;
  final List<String> contactsLabels;
  final String activeContact;
  final bool searching;

  ContactsState({
    @required this.contacts,
    @required this.contactsLabels,
    @required this.activeContact,
    @required this.searching,
  });

  factory ContactsState.initial() => ContactsState(
        contacts: <Contact>[],
        contactsLabels: <String>[],
        activeContact: null,
        searching: false,
      );

  ContactsState copyWith({
    List<Contact> contacts,
    List<String> contactsLabels,
    String activeContact,
    bool searching,
  }) =>
      ContactsState(
        contacts: contacts ?? this.contacts,
        contactsLabels: contactsLabels ?? this.contactsLabels,
        activeContact: activeContact ?? this.activeContact,
        searching: searching ?? this.searching,
      );
}
