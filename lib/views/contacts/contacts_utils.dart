import 'dart:typed_data';
import 'package:contacts_service/contacts_service.dart';
import 'package:dispatcher/extensions/string_extensions.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/views/contacts/contacts_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

/// Ask for permission to access the device contacts.
Future<void> askContactsPermissions(
  ContactsViewModel viewModel,
  BuildContext context,
) async {
  PermissionStatus permissionStatus = await Permission.contacts.request();
  if (permissionStatus == PermissionStatus.granted) {
    _loadContacts(viewModel, context);
  } else {
    // askContactsPermissions(viewModel);
    // Open app settings??
  }
}

Future<bool> hasContactsPermission() => Permission.contacts.isGranted;

/// Refreshes the contact list. This gets an initial list of contacts and then
/// loads the avatars afterwards. This allows us to display an initial list
/// without having to wait for the avatars to finish loading.
Future<void> _loadContacts(
  ContactsViewModel viewModel,
  BuildContext context,
) async {
  bool isGranted = await hasContactsPermission();
  if (isGranted) {
    List<String> labels = <String>[AppLocalizations.of(context).all];

    // Build contacts list.
    List<Contact> contacts = (await ContactsService.getContacts(
      withThumbnails: false,
      iOSLocalizedLabels: false,
    ))
        .toList();

    // Update the avatars abd build the labels list.
    for (final contact in contacts) {
      Uint8List avatar = await ContactsService.getAvatar(contact);
      if (avatar == null) {
        contact.avatar = null;
      } else {
        contact.avatar = avatar;
      }

      for (Item item in contact.emails.where((email) => (email.label != ''))) {
        String label = item.label.capitalize();
        if (!labels.contains(label)) {
          labels.add(label);
        }
      }
    }

    viewModel.setContacts(contacts);
    viewModel.setContactsLabels(labels);
  }
}
