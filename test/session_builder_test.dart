import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:test/test.dart';
import 'test_in_memory_signal_protocol_store.dart';

void main() {
  final aliceAddress = SignalProtocolAddress('+14151111111', 1);
  final bobAddress = SignalProtocolAddress('+14152222222', 1);

  test('testPreKey', () {
    TestInMemorySignalProtocolStore aliceStore =
        TestInMemorySignalProtocolStore();

    SessionBuilder aliceSessionBuilder =
        SessionBuilder.fromSignalStore(aliceStore, bobAddress);

    TestInMemorySignalProtocolStore bobStore =
        TestInMemorySignalProtocolStore();

    ECKeyPair bobPreKeyPair = Curve.generateKeyPair();
    ECKeyPair bobSignedPreKeyPair = Curve.generateKeyPair();

    Uint8List bobSignedPreKeySignature = Curve.calculateSignature(
      bobStore.getIdentityKeyPair().getPrivateKey(),
      bobSignedPreKeyPair.publicKey.serialize(),
    );

    PreKeyBundle bobPreKey = PreKeyBundle(
      bobStore.getLocalRegistrationId(),
      1,
      31337,
      bobPreKeyPair.publicKey,
      22,
      bobSignedPreKeyPair.publicKey,
      bobSignedPreKeySignature,
      bobStore.getIdentityKeyPair().getPublicKey(),
    );

    aliceSessionBuilder.processPreKeyBundle(bobPreKey);

    assert(aliceStore.containsSession(bobAddress));
    assert(
        aliceStore.loadSession(bobAddress).sessionState.getSessionVersion() ==
            3);

    final String originalMessage = 'Hello World!';
    SessionCipher aliceSessionCipher =
        SessionCipher.fromStore(aliceStore, bobAddress);

    CiphertextMessage outgoingMessage =
        aliceSessionCipher.encrypt(utf8.encode(originalMessage));

    assert(outgoingMessage.getType() == CiphertextMessage.PREKEY_TYPE);

    Uint8List serializedCipherText = outgoingMessage.serialize();
    String cipherTextStr = String.fromCharCodes(serializedCipherText);

    PreKeySignalMessage incomingMessage =
        PreKeySignalMessage(Uint8List.fromList(cipherTextStr.codeUnits));

    bobStore.storePreKey(
        31337, PreKeyRecord(bobPreKey.getPreKeyId(), bobPreKeyPair));

    bobStore.storeSignedPreKey(
      22,
      SignedPreKeyRecord(
        22,
        Int64(DateTime.now().millisecondsSinceEpoch),
        bobSignedPreKeyPair,
        bobSignedPreKeySignature,
      ),
    );

    SessionCipher bobSessionCipher =
        SessionCipher.fromStore(bobStore, aliceAddress);

    Uint8List plaintext = bobSessionCipher.decrypt(incomingMessage);
    String result = utf8.decode(plaintext, allowMalformed: true);
    assert(originalMessage == result);
  });
}
