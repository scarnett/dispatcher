import 'dart:typed_data';
import 'package:dispatcher/utils/eq.dart' as eq;
import 'package:get_storage/get_storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

class DispatcherIdentityKeyStore extends IdentityKeyStore {
  final GetStorage store = GetStorage('ClientTrustedKeys');

  DispatcherIdentityKeyStore();

  DispatcherIdentityKeyStore.write(
    IdentityKeyPair identityKeyPair,
    int localRegistrationId,
  ) {
    store.write('identityKeyPair', identityKeyPair.serialize().toList());
    store.write('localRegistrationId', localRegistrationId);
  }

  @override
  IdentityKey getIdentity(
    SignalProtocolAddress address,
  ) =>
      IdentityKey.fromBytes(store.read(address.toString()), 0);

  @override
  IdentityKeyPair getIdentityKeyPair() {
    List<dynamic> identityKeyPairDynList = store.read('identityKeyPair');
    List<int> identityKeyPairIntList =
        identityKeyPairDynList.map((s) => s as int).toList();

    return IdentityKeyPair.fromSerialized(
        Uint8List.fromList(identityKeyPairIntList));
  }

  @override
  int getLocalRegistrationId() => store.read('localRegistrationId');

  @override
  bool isTrustedIdentity(
    SignalProtocolAddress address,
    IdentityKey identityKey,
    Direction direction,
  ) {
    List<dynamic> trustedDynList = store.read(address.toString());
    List<int> trustedIntList = trustedDynList.map((s) => s as int).toList();
    return ((trustedDynList == null) ||
        eq.eq(Uint8List.fromList(trustedIntList), identityKey.serialize()));
  }

  @override
  bool saveIdentity(
    SignalProtocolAddress address,
    IdentityKey identityKey,
  ) {
    List<dynamic> exitingDynList = store.read(address.toString());
    if (exitingDynList == null) {
      store.write(address.toString(), identityKey.serialize().toList());
      return true;
    }

    List<int> exitingIntList = exitingDynList.map((s) => s as int).toList();
    if (identityKey.serialize() != Uint8List.fromList(exitingIntList)) {
      store.write(address.toString(), identityKey.serialize().toList());
      return true;
    }

    return false;
  }
}
