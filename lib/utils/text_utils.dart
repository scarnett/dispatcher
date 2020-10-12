/// Removes emojis from a string.
String removeEmojis(
  String str,
) {
  if (str == null) {
    return null;
  }

  final RegExp regex = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
  return str.replaceAll(regex, '');
}

/// Removes non-alpha numeric characters from a string.
String removeNonAlphaNumeric(
  String str,
) {
  final RegExp regex = RegExp(r'[^A-Za-z0-9 ]');
  return str.replaceAll(regex, '');
}
