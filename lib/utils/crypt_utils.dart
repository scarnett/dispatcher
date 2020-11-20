import 'dart:convert';
import 'dart:typed_data';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/storage/storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart' as signal;
import 'package:openpgp/key_options.dart';
import 'package:openpgp/key_pair.dart';
import 'package:openpgp/openpgp.dart';
import 'package:openpgp/options.dart';

/// Initiates the storage boxes and generates the client keys during install time
Future<void> installClientKeys() async {
  // Init Storage
  await GetStorage.init('ClientUserKeys');
  await GetStorage.init('ClientTrustedKeys');
  await GetStorage.init('ClientPreKeys');
  await GetStorage.init('ClientSignedPreKey');

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
signal.SessionCipher buildSessionCipher(
  RoomUser roomUser1,
  RoomUser roomUser2,
) {
  DispatcherIdentityKeyStore identityKeyStore = DispatcherIdentityKeyStore();
  DispatcherSignalProtocolStore _sessionStore = DispatcherSignalProtocolStore(
    identityKeyStore.getIdentityKeyPair(),
    identityKeyStore.getLocalRegistrationId(),
  );

  signal.SignalProtocolAddress _connectionUserRemoteAddress =
      signal.SignalProtocolAddress(roomUser1.user.identifier, 1);

  signal.PreKeyRecord _preKeyRecord =
      _sessionStore.loadPreKey(roomUser2.preKey.keyId);

  signal.ECPublicKey _signedPreKeyRecord = signal.Curve.decodePoint(
      Uint8List.fromList(roomUser2.user.key.sigSignedPublicKey.codeUnits), 0);

  Uint8List signedPreKeySignature =
      Uint8List.fromList(roomUser2.user.key.sigSignedPrekeySignature.codeUnits);

  signal.IdentityKey _identityKey = signal.IdentityKey.fromBytes(
      Uint8List.fromList(roomUser2.user.key.sigIdentityPublicKey.codeUnits), 0);

  signal.PreKeyBundle _connectionUserPreKey = signal.PreKeyBundle(
    roomUser2.user.key.sigRegistrationId,
    1, // TODO!
    _preKeyRecord.id,
    _preKeyRecord.getKeyPair().publicKey,
    0, // TODO!
    _signedPreKeyRecord,
    signedPreKeySignature,
    _identityKey,
  );

  signal.SessionBuilder.fromSignalStore(
    _sessionStore,
    _connectionUserRemoteAddress,
  ).processPreKeyBundle(_connectionUserPreKey);

  return signal.SessionCipher.fromStore(
    _sessionStore,
    _connectionUserRemoteAddress,
  );
}
