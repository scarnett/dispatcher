import 'dart:convert';
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
      signal.KeyHelper.generatePreKeys(0, 10); // TODO!

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
  User user,
  int preKeyId,
  int signedPreKeyId,
) {
  signal.InMemorySessionStore _sessionStore = signal.InMemorySessionStore();
  DispatcherPreKeyStore _preKeyStore = DispatcherPreKeyStore();
  DispatcherIdentityKeyStore _identityKeyStore = DispatcherIdentityKeyStore();
  DispatcherSignedPreKeyStore _signedPreKeyStore =
      DispatcherSignedPreKeyStore();

  signal.SignalProtocolAddress _remoteAddress =
      signal.SignalProtocolAddress(user.identifier, 1);

  signal.PreKeyRecord _preKeyRecord = _preKeyStore.loadPreKey(preKeyId);

  signal.SignedPreKeyRecord _signedPreKey =
      _signedPreKeyStore.loadSignedPreKey(signedPreKeyId);

  signal.PreKeyBundle _preKeyBundle = signal.PreKeyBundle(
    _identityKeyStore.getLocalRegistrationId(),
    1, // TODO!
    _preKeyRecord.id,
    _preKeyRecord.getKeyPair().publicKey,
    _signedPreKey.id,
    _signedPreKey.getKeyPair().publicKey,
    _signedPreKey.signature,
    _identityKeyStore.getIdentityKeyPair().getPublicKey(),
  );

  signal.SessionBuilder _sessionBuilder = signal.SessionBuilder(
    _sessionStore,
    _preKeyStore,
    _signedPreKeyStore,
    _identityKeyStore,
    _remoteAddress,
  );

  _sessionBuilder.processPreKeyBundle(_preKeyBundle);

  signal.SessionCipher _sessionCipher = signal.SessionCipher(
    _sessionStore,
    _preKeyStore,
    _signedPreKeyStore,
    _identityKeyStore,
    _remoteAddress,
  );

  return _sessionCipher;
}
