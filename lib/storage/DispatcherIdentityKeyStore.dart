import 'dart:typed_data';

import 'package:dispatcher/utils/eq.dart';
import 'package:get_storage/get_storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

class DispatcherIdentityKeyStore extends IdentityKeyStore {
  final GetStorage store = GetStorage('ClientTrustedKeys');

  DispatcherIdentityKeyStore();

  DispatcherIdentityKeyStore.write(
    IdentityKeyPair identityKeyPair,
    int localRegistrationId,
  ) {
    store.write(
        'identityKeyPair', String.fromCharCodes(identityKeyPair.serialize()));
    store.write('localRegistrationId', localRegistrationId);
  }

  @override
  IdentityKey getIdentity(
    SignalProtocolAddress address,
  ) =>
      store.read(address.toString());

  @override
  IdentityKeyPair getIdentityKeyPair() => IdentityKeyPair.fromSerialized(
      Uint8List.fromList(store.read('identityKeyPair').codeUnits));

  @override
  int getLocalRegistrationId() => store.read('localRegistrationId');

  @override
  bool isTrustedIdentity(
    SignalProtocolAddress address,
    IdentityKey identityKey,
    Direction direction,
  ) {
    dynamic trusted =
        Uint8List.fromList(store.read(address.toString()).codeUnits);

    return ((trusted == null) || eq(trusted, identityKey.serialize()));
  }

  @override
  bool saveIdentity(
    SignalProtocolAddress address,
    IdentityKey identityKey,
  ) {
    dynamic existing =
        Uint8List.fromList(store.read(address.toString()).codeUnits);

    if (identityKey.serialize() != existing) {
      store.write(
          address.toString(), String.fromCharCodes(identityKey.serialize()));

      return true;
    }

    return false;
  }
}
