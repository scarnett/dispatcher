import 'package:dispatcher/extensions/extensions.dart';
import 'package:dispatcher/utils/text_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Gets the initials from someones name
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

/// Gets the thumbnail url of an avatar
Future<String> getAvatarThumbnailUrl(
  StorageReference storageRef, {
  int width = 200,
  int height = 200,
}) async {
  String fileName = await storageRef.getName();
  List<String> fileNameParts = fileName.split('.')
    ..insert(0, 'thumbs%2F')
    ..insert(2, '_${width}x$height.');

  String fileUrl = await storageRef.getDownloadURL();
  fileUrl =
      fileUrl.replaceAll(fileName.replaceAll('}', '%7D'), fileNameParts.join());
  return fileUrl;
}
