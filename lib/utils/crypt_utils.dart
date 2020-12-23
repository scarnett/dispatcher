import 'dart:convert';
import 'dart:typed_data';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/storage/storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart' as signal;
import 'package:openpgp/key_options.dart';
import 'package:openpgp/key_pair.dart';
import 'package:openpgp/openpgp.dart';
import 'package:openpgp/options.dart';

/// Initiates the storage boxes and generates the client keys during install time
Future<void> installClientKeys({
  clearStorage: false,
}) async {
  await initStorageBoxes();

  if (clearStorage) {
    await clearStorageBoxes();
  }

  DispatcherKeyStore keyStore = DispatcherKeyStore();
  if (!keyStore.hasData()) {
    signal.IdentityKeyPair identityKeyPair = generateIdentityKeyPar();
    generateSignedPreKey(identityKeyPair);
    generatePreKeys();
  }
}

/// Generates the signal identity keypair
signal.IdentityKeyPair generateIdentityKeyPar() {
  signal.IdentityKeyPair identityKeyPair =
      signal.KeyHelper.generateIdentityKeyPair();

  DispatcherIdentityKeyStore.write(
    identityKeyPair,
    signal.KeyHelper.generateRegistrationId(false),
  );

  return identityKeyPair;
}

/// Generates the signal signed prekey
void generateSignedPreKey(
  signal.IdentityKeyPair identityKeyPair,
) {
  signal.SignedPreKeyRecord signedPreKey =
      signal.KeyHelper.generateSignedPreKey(identityKeyPair, 0);

  DispatcherSignedPreKeyStore signedPreKeyStore = DispatcherSignedPreKeyStore();
  signedPreKeyStore.storeSignedPreKey(signedPreKey.id, signedPreKey);
}

/// Generates the signal prekeys
void generatePreKeys() {
  DispatcherPreKeyStore preKeyStore = DispatcherPreKeyStore();
  List<signal.PreKeyRecord> preKeys =
      signal.KeyHelper.generatePreKeys(1, 25); // TODO! config

  for (signal.PreKeyRecord preKey in preKeys) {
    preKeyStore.storePreKey(preKey.id, preKey);
  }
}

/// Generates a pgp keypair for the user
Future<KeyPair> generateUserKeyPair(
  firebase.User firebaseUser,
) async =>
    await OpenPGP.generate(
      options: Options(
        name: firebaseUser.displayName,
        email: firebaseUser.email,
        passphrase: firebaseUser.uid,
        keyOptions: KeyOptions(
          rsaBits: 2048,
          cipher: Cypher.aes128,
          compression: Compression.none,
          hash: Hash.sha256,
          compressionLevel: 0,
        ),
      ),
    );

/// Encrypts and optionally encodes some text
Future<String> encrypt(
  String text,
  String publicKey, {
  bool encodeText = true,
}) async {
  if (encodeText) {
    String encryptedText = await OpenPGP.encrypt(text, publicKey);
    return encode(encryptedText);
  }

  return OpenPGP.encrypt(text, publicKey);
}

/// Decrypts and optionally decodes some text
Future<String> decrypt(
  String text,
  String privateKey,
  String passphrase, {
  bool decodeText = true,
}) {
  if (decodeText) {
    return OpenPGP.decrypt(decode(text), privateKey, passphrase);
  }

  return OpenPGP.decrypt(text, privateKey, passphrase);
}

/// Encodes some text
String encode(
  String text,
) {
  if (text == null) {
    return null;
  }

  return base64.encode(utf8.encode(text));
}

/// Decodes some text
String decode(
  String str,
) {
  if (str == null) {
    return null;
  }

  return String.fromCharCodes(base64.decode(str));
}

/// Builds the signal session cipher
void buildSessionCipher(
  User user,
  DispatcherSignalProtocolStore store,
) async {
  signal.SignalProtocolAddress _address =
      signal.SignalProtocolAddress(user.identifier, 1);

  signal.SessionBuilder _sessionBuilder =
      signal.SessionBuilder.fromSignalStore(store, _address);

  signal.PreKeyRecord _preKeyRecord = store.loadPreKey(13); // TODO!

  signal.ECPublicKey _signedPreKeyRecord = signal.Curve.decodePoint(
      Uint8List.fromList(user.key.sigSignedPublicKey), 0);

  Uint8List _signedPreKeySignature =
      Uint8List.fromList(user.key.sigSignedPrekeySignature);

  signal.IdentityKey _identityKey = signal.IdentityKey.fromBytes(
      Uint8List.fromList(user.key.sigIdentityPublicKey), 0);

  signal.PreKeyBundle _userPreKey = signal.PreKeyBundle(
    user.key.sigRegistrationId,
    1, // TODO!
    _preKeyRecord.id,
    _preKeyRecord.getKeyPair().publicKey,
    0, // TODO!
    _signedPreKeyRecord,
    _signedPreKeySignature,
    _identityKey,
  );

  _sessionBuilder.processPreKeyBundle(_userPreKey);
}

String decryptMessage(
  signal.SessionCipher sessionCipher,
  List<int> message,
) {
  signal.PreKeySignalMessage incomingMessage =
      signal.PreKeySignalMessage(Uint8List.fromList(message));

  Uint8List plainText = sessionCipher.decrypt(incomingMessage);
  return utf8.decode(plainText, allowMalformed: true);
}
