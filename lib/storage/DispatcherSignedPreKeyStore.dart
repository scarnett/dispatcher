import 'dart:io';
import 'dart:typed_data';
import 'package:get_storage/get_storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

class DispatcherSignedPreKeyStore extends SignedPreKeyStore {
  final GetStorage store = GetStorage('ClientSignedPreKey');

  @override
  SignedPreKeyRecord loadSignedPreKey(
    int signedPreKeyId,
  ) {
    try {
      if (!store.hasData(signedPreKeyId.toString())) {
        throw InvalidKeyIdException(
            'No such signedprekeyrecord! $signedPreKeyId');
      }

      return SignedPreKeyRecord.fromSerialized(
          Uint8List.fromList(store.read(signedPreKeyId.toString()).codeUnits));
    } on IOException catch (e) {
      throw AssertionError(e);
    }
  }

  @override
  List<SignedPreKeyRecord> loadSignedPreKeys() {
    try {
      List<SignedPreKeyRecord> results = <SignedPreKeyRecord>[];
      for (dynamic serialized in store.getValues()) {
        results.add(SignedPreKeyRecord.fromSerialized(
            Uint8List.fromList(serialized.codeUnits)));
      }

      return results;
    } on IOException catch (e) {
      throw AssertionError(e);
    }
  }

  @override
  void storeSignedPreKey(
    int signedPreKeyId,
    SignedPreKeyRecord record,
  ) =>
      store.write(
          signedPreKeyId.toString(), String.fromCharCodes(record.serialize()));

  @override
  bool containsSignedPreKey(
    int signedPreKeyId,
  ) =>
      store.hasData(signedPreKeyId.toString());

  @override
  void removeSignedPreKey(
    int signedPreKeyId,
  ) =>
      store.remove(signedPreKeyId.toString());
}
