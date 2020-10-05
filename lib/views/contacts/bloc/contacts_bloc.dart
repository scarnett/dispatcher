import 'dart:typed_data';
import 'package:contacts_service/contacts_service.dart';
import 'package:dispatcher/extensions/extensions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/views/contacts/bloc/contacts_events.dart';
import 'package:dispatcher/views/contacts/bloc/contacts_state.dart';
import 'package:dispatcher/views/contacts/contacts_utils.dart';
import 'package:dispatcher/views/contacts/models/search.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  Logger logger = Logger();

  ContactsBloc() : super(ContactsState.initial());

  ContactsState get initialState => ContactsState.initial();

  @override
  Stream<ContactsState> mapEventToState(
    ContactsEvent event,
  ) async* {
    if (event is FetchContactsData) {
      yield* _mapFetchContactsDataToStates(event, state);
    } else if (event is ActiveContact) {
      yield _mapActiveContactToStates(event);
    } else if (event is ClearActiveContact) {
      yield _mapClearActiveContactToStates(event);
    } else if (event is SearchChanged) {
      yield _mapSearchChangedToStates(event, state);
    } else if (event is ClearSearch) {
      yield _mapClearSearchToStates(event, state);
    } else if (event is Searching) {
      yield _mapSearchingToStates(event);
    } else if (event is ActiveContactTab) {
      yield _mapActiveContactTabToStates(event);
    }
  }

  Stream<ContactsState> _mapFetchContactsDataToStates(
    FetchContactsData event,
    ContactsState state,
  ) async* {
    try {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      if (permissionStatus == PermissionStatus.granted) {
        List<String> labels = <String>[AppLocalizations.of(event.context).all];

        // Build contacts list.
        List<Contact> contacts = (await ContactsService.getContacts(
          withThumbnails: false,
          iOSLocalizedLabels: false,
        ))
            .toList();

        // Update the avatars and build the labels list.
        for (final contact in contacts) {
          Uint8List avatar = await ContactsService.getAvatar(contact);
          if (avatar == null) {
            contact.avatar = null;
          } else {
            contact.avatar = avatar;
          }

          for (Item item
              in contact.emails.where((email) => (email.label != ''))) {
            String label = item.label.capitalize();
            if (!labels.contains(label)) {
              labels.add(label);
            }
          }
        }

        yield state.copyWith(
          contacts: contacts,
          contactLabels: labels..sort(),
        );
      } else {
        yield ContactsState.loadFail();
      }
    } catch (e) {
      logger.e(e.toString());
      yield ContactsState.loadFail();
    }
  }

  ContactsState _mapActiveContactToStates(
    ActiveContact event,
  ) =>
      state.copyWith(
        activeContact: event.contactId,
        searching: false,
      );

  ContactsState _mapClearActiveContactToStates(
    ClearActiveContact event,
  ) =>
      state.copyWith(
        activeContact: null,
      );

  ContactsState _mapSearchChangedToStates(
    SearchChanged event,
    ContactsState state,
  ) {
    final Search search = Search.dirty(event.criteria);

    return state.copyWith(
      filteredContacts: getFilteredContacts(
        state,
        state.activeContactTabIndex,
        search: search,
      ),
      search: search,
    );
  }

  ContactsState _mapClearSearchToStates(
    ClearSearch event,
    ContactsState state,
  ) =>
      state.copyWith(
        filteredContacts: filterByTabIndex(state, state.activeContactTabIndex),
        search: Search.dirty(),
      );

  ContactsState _mapSearchingToStates(
    Searching event,
  ) =>
      state.copyWith(
        filteredContacts: event.searching
            ? state.filteredContacts
            : filterByTabIndex(state, state.activeContactTabIndex),
        search: event.searching ? state.search : Search.dirty(),
        searching: event.searching,
      );

  ContactsState _mapActiveContactTabToStates(
    ActiveContactTab event,
  ) =>
      state.copyWith(
        filteredContacts:
            getFilteredContacts(state, event.activeContactTabIndex),
        activeContactTabIndex: event.activeContactTabIndex,
      );
}
