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
            'No such signedprekeyrecord; $signedPreKeyId');
      }

      List<dynamic> signedPrekeyDynList = store.read(signedPreKeyId.toString());
      List<int> signedPrekeyIntList =
          signedPrekeyDynList.map((s) => s as int).toList();

      return SignedPreKeyRecord.fromSerialized(
          Uint8List.fromList(signedPrekeyIntList));
    } on IOException catch (e) {
      throw AssertionError(e);
    }
  }

  @override
  List<SignedPreKeyRecord> loadSignedPreKeys() {
    try {
      List<SignedPreKeyRecord> results = <SignedPreKeyRecord>[];
      for (dynamic signedPrekey in store.getValues()) {
        List<int> signedPrekeyIntList =
            signedPrekey.map((s) => s as int).toList();

        results.add(SignedPreKeyRecord.fromSerialized(
            Uint8List.fromList(signedPrekeyIntList)));
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
      store.write(signedPreKeyId.toString(), record.serialize().toList());

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
