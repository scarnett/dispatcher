import 'package:get_storage/get_storage.dart';

const List<String> storageBoxes = [
  'ClientSessions',
  'ClientUserKeys',
  'ClientTrustedKeys',
  'ClientPreKeys',
  'ClientSignedPreKey',
];

Future<void> initStorageBoxes([
  List<String> boxes = storageBoxes,
]) async {
  for (String box in boxes) {
    await GetStorage.init(box);
  }
}

Future<void> clearStorageBoxes([
  List<String> boxes = storageBoxes,
]) async {
  for (String box in boxes) {
    await GetStorage(box).erase();
  }
}
