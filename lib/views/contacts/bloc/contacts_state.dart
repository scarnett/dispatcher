import 'package:contacts_service/contacts_service.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/views/contacts/models/search.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class ContactsState extends Equatable {
  final UserInviteCode inviteCode;
  final List<Contact> contacts;
  final List<Contact> filteredContacts;
  final List<String> contactLabels;
  final String activeContact;
  final Search search;
  final bool searching;
  final int activeContactTabIndex;

  const ContactsState._({
    this.inviteCode,
    this.contacts,
    this.filteredContacts,
    this.contactLabels,
    this.activeContact,
    this.search = const Search.pure(),
    this.searching = false,
    this.activeContactTabIndex = 0,
  });

  const ContactsState.initial() : this._();

  const ContactsState.loadFail() : this._();

  ContactsState copyWith({
    UserInviteCode inviteCode,
    List<Contact> contacts,
    List<Contact> filteredContacts,
    List<String> contactLabels,
    String activeContact,
    Search search,
    bool searching,
    int activeContactTabIndex,
  }) =>
      ContactsState._(
        inviteCode: inviteCode ?? this.inviteCode,
        contacts: contacts ?? this.contacts,
        filteredContacts: filteredContacts ?? this.filteredContacts,
        contactLabels: contactLabels ?? this.contactLabels,
        activeContact: activeContact,
        search: search ?? this.search,
        searching: searching ?? this.searching,
        activeContactTabIndex:
            activeContactTabIndex ?? this.activeContactTabIndex,
      );

  @override
  List<Object> get props => [
        inviteCode,
        contacts,
        filteredContacts,
        contactLabels,
        activeContact,
        search,
        searching,
        activeContactTabIndex,
      ];

  @override
  String toString() =>
      'ContactsState{inviteCode: $inviteCode, contacts: ${contacts?.length}, ' +
      'filteredContacts: ${filteredContacts?.length}, ' +
      'contactLabels: $contactLabels, activeContact: $activeContact, ' +
      'search: $search, searching: $searching, activeContactTabIndex: $activeContactTabIndex}';
}
