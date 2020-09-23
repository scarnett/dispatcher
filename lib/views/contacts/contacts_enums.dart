enum ContactsMode {
  CONTACTS,
  CONTACT,
}

extension ContactsModeExtension on ContactsMode {
  int get pageIndex {
    switch (this) {
      case ContactsMode.CONTACTS:
        return 0;

      case ContactsMode.CONTACT:
        return 1;

      default:
        return -1;
    }
  }
}
