import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object> get props => [];
}

class FetchInviteCodeData extends ContactsEvent {
  final GraphQLClient client;
  final firebase.User firebaseUser;

  const FetchInviteCodeData(
    this.client,
    this.firebaseUser,
  );

  @override
  List<Object> get props => [client, firebaseUser];
}

class FetchContactsData extends ContactsEvent {
  final BuildContext context;

  const FetchContactsData(this.context);

  @override
  List<Object> get props => [context];
}

class ActiveContact extends ContactsEvent {
  final String contactId;

  const ActiveContact(this.contactId);

  @override
  List<Object> get props => [contactId];
}

class ClearActiveContact extends ContactsEvent {
  const ClearActiveContact();
}

class SearchChanged extends ContactsEvent {
  final String criteria;

  const SearchChanged(
    this.criteria,
  );

  @override
  List<Object> get props => [criteria];
}

class SearchSubmitted extends ContactsEvent {
  const SearchSubmitted();
}

class ClearSearch extends ContactsEvent {
  const ClearSearch();
}

class Searching extends ContactsEvent {
  final bool searching;

  const Searching(this.searching);

  @override
  List<Object> get props => [searching];
}

class ActiveContactTab extends ContactsEvent {
  final int activeContactTabIndex;

  const ActiveContactTab(this.activeContactTabIndex);

  @override
  List<Object> get props => [activeContactTabIndex];
}
