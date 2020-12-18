import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:libsignal_protocol_dart/src/IdentityKey.dart';
import 'package:libsignal_protocol_dart/src/IdentityKeyPair.dart';
import 'package:libsignal_protocol_dart/src/ecc/Curve.dart';
import 'package:libsignal_protocol_dart/src/state/impl/InMemorySignalProtocolStore.dart';
import 'package:libsignal_protocol_dart/src/util/KeyHelper.dart';

class TestInMemorySignalProtocolStore extends InMemorySignalProtocolStore {
  TestInMemorySignalProtocolStore()
      : super(
          _generateIdentityKeyPair(),
          _generateRegistrationId(),
        );

  static IdentityKeyPair _generateIdentityKeyPair() {
    ECKeyPair identityKeyPairKeys = Curve.generateKeyPair();

    return IdentityKeyPair(
      IdentityKey(identityKeyPairKeys.publicKey),
      identityKeyPairKeys.privateKey,
    );
  }

  static int _generateRegistrationId() =>
      KeyHelper.generateRegistrationId(false);
}
