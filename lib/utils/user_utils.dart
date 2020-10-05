import 'package:dispatcher/extensions/extensions.dart';
import 'package:dispatcher/utils/text_utils.dart';

/// Gets the initial from someones name.
String getNameInitials(
  String name,
) {
  if (name.isNullEmptyOrWhitespace) {
    return '';
  }

  List<String> parts = removeNonAlphaNumeric(name)
      .split(' ')
      .where((element) => (element.trim() != ''))
      .toList();

  if (parts.length == 1) {
    return name.substring(0, 1).toUpperCase();
  }

  String firstName = parts[0];
  String firstInitial = firstName.substring(0, 1).toUpperCase();
  String lastName = parts[parts.length - 1];
  String lastInitial = lastName.substring(0, 1).toUpperCase();
  return '$firstInitial $lastInitial';
}
