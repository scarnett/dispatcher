import 'dart:io';
import 'dart:typed_data';
import 'package:get_storage/get_storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

class DispatcherPreKeyStore extends PreKeyStore {
  final GetStorage store = GetStorage('ClientPreKeys');

  @override
  bool containsPreKey(
    int preKeyId,
  ) =>
      store.hasData(preKeyId.toString());

  @override
  PreKeyRecord loadPreKey(
    int preKeyId,
  ) {
    try {
      if (!store.hasData(preKeyId.toString())) {
        throw InvalidKeyIdException('No such prekeyrecord!');
      }

      List<dynamic> prekeyDynList = store.read(preKeyId.toString());
      List<int> prekeyIntList = prekeyDynList.map((s) => s as int).toList();
      return PreKeyRecord.fromBuffer(Uint8List.fromList(prekeyIntList));
    } on IOException catch (e) {
      throw AssertionError(e);
    }
  }

  @override
  void removePreKey(
    int preKeyId,
  ) =>
      store.remove(preKeyId.toString());

  @override
  void storePreKey(
    int preKeyId,
    PreKeyRecord record,
  ) =>
      store.write(preKeyId.toString(), record.serialize().toList());
}
