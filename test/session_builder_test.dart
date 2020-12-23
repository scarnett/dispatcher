import 'dart:convert';
import 'dart:typed_data';
import 'package:fixnum/fixnum.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:test/test.dart';
import 'test_in_memory_signal_protocol_store.dart';

void main() {
  SignalProtocolAddress aliceAddress = SignalProtocolAddress('+14151111111', 1);
  TestInMemorySignalProtocolStore aliceStore;
  SessionBuilder aliceSessionBuilder;

  SignalProtocolAddress bobAddress = SignalProtocolAddress('+14152222222', 1);
  TestInMemorySignalProtocolStore bobStore;
  SessionBuilder bobSessionBuilder;
  PreKeyBundle bobPreKey;

  aliceSetup() {
    aliceStore = TestInMemorySignalProtocolStore();
    aliceSessionBuilder =
        SessionBuilder.fromSignalStore(aliceStore, bobAddress);
  }

  bobSetup(
    int signedPreKeyId,
    int preKeyId,
  ) {
    bobStore = TestInMemorySignalProtocolStore();
    bobSessionBuilder = SessionBuilder.fromSignalStore(bobStore, aliceAddress);

    ECKeyPair bobPreKeyPair = Curve.generateKeyPair();
    ECKeyPair bobSignedPreKeyPair = Curve.generateKeyPair();
    Uint8List bobSignedPreKeySignature = Curve.calculateSignature(
      bobStore.getIdentityKeyPair().getPrivateKey(),
      bobSignedPreKeyPair.publicKey.serialize(),
    );

    bobPreKey = PreKeyBundle(
      bobStore.getLocalRegistrationId(),
      1,
      preKeyId,
      bobPreKeyPair.publicKey,
      signedPreKeyId,
      bobSignedPreKeyPair.publicKey,
      bobSignedPreKeySignature,
      bobStore.getIdentityKeyPair().getPublicKey(),
    );

    bobStore.storePreKey(
        preKeyId, PreKeyRecord(bobPreKey.getPreKeyId(), bobPreKeyPair));

    bobStore.storeSignedPreKey(
      signedPreKeyId,
      SignedPreKeyRecord(
        signedPreKeyId,
        Int64(DateTime.now().millisecondsSinceEpoch),
        bobSignedPreKeyPair,
        bobSignedPreKeySignature,
      ),
    );
  }

  test('testPreKey', () {
    aliceSetup();
    bobSetup(22, 31337);

    aliceSessionBuilder.processPreKeyBundle(bobPreKey);
    assert(aliceStore.containsSession(bobAddress));

    final String originalMessage = 'Hello World!';
    SessionCipher aliceSessionCipher =
        SessionCipher.fromStore(aliceStore, bobAddress);

    CiphertextMessage aliceOutgoingMessage =
        aliceSessionCipher.encrypt(utf8.encode(originalMessage));

    assert(aliceOutgoingMessage.getType() == CiphertextMessage.PREKEY_TYPE);

    Uint8List serializedCipherText = aliceOutgoingMessage.serialize();
    PreKeySignalMessage incomingMessage =
        PreKeySignalMessage(Uint8List.fromList(serializedCipherText.toList()));

    SessionCipher bobSessionCipher =
        SessionCipher.fromStore(bobStore, aliceAddress);

    Uint8List plainText = bobSessionCipher.decrypt(incomingMessage);
    String result = utf8.decode(plainText, allowMalformed: true);

    assert(originalMessage == result);
    assert(bobStore.containsSession(aliceAddress));
    assert(
        bobStore.loadSession(aliceAddress).sessionState.aliceBaseKey != null);

    CiphertextMessage bobOutgoingMessage =
        bobSessionCipher.encrypt(utf8.encode(originalMessage));

    assert(bobOutgoingMessage.getType() == CiphertextMessage.WHISPER_TYPE);

    Uint8List alicePlainText = aliceSessionCipher.decryptFromSignal(
        SignalMessage.fromSerialized(bobOutgoingMessage.serialize()));

    result = utf8.decode(alicePlainText, allowMalformed: true);
    assert(originalMessage == result);
  });
}
