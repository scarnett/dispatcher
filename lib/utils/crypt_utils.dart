import 'dart:convert';
import 'package:dispatcher/storage/storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart' as signal;
import 'package:openpgp/key_options.dart';
import 'package:openpgp/key_pair.dart';
import 'package:openpgp/openpgp.dart';
import 'package:openpgp/options.dart';

Future<void> installClientKeys() async {
  // Init Storage
  await GetStorage.init('ClientUserKeys');
  await GetStorage.init('ClientTrustedKeys');
  await GetStorage.init('ClientPreKeys');
  await GetStorage.init('ClientSignedPreKey');

  signal.IdentityKeyPair identityKeyPair =
      signal.KeyHelper.generateIdentityKeyPair();

  DispatcherIdentityKeyStore.write(
    identityKeyPair,
    signal.KeyHelper.generateRegistrationId(false),
  );

  DispatcherPreKeyStore preKeyStore = DispatcherPreKeyStore();
  DispatcherSignedPreKeyStore signedPreKeyStore = DispatcherSignedPreKeyStore();

  List<signal.PreKeyRecord> preKeys =
      signal.KeyHelper.generatePreKeys(0, 10); // TODO!

  for (signal.PreKeyRecord preKey in preKeys) {
    preKeyStore.storePreKey(preKey.id, preKey);
  }

  signal.SignedPreKeyRecord signedPreKey =
      signal.KeyHelper.generateSignedPreKey(identityKeyPair, 0);

  signedPreKeyStore.storeSignedPreKey(signedPreKey.id, signedPreKey);
}

/*
ClientKeys generateClientKeys() {
  signal.IdentityKeyPair sigIdentityKeyPair =
      signal.KeyHelper.generateIdentityKeyPair();

  // Generate the signal keys
  int sigRegistrationId = signal.KeyHelper.generateRegistrationId(false);
  List<signal.PreKeyRecord> sigPreKeys =
      signal.KeyHelper.generatePreKeys(0, 50);

  List<ClientPreKey> sigPreKeysList = sigPreKeys
      .map((signal.PreKeyRecord preKey) => ClientPreKey(
            keyId: preKey.id,
            publicKey: encode(String.fromCharCodes(
                preKey.getKeyPair().publicKey.serialize())),
            privateKey: encode(String.fromCharCodes(
                preKey.getKeyPair().privateKey.serialize())),
          ))
      .toList();

  signal.InMemorySignalProtocolStore sigSessionStore =
      signal.InMemorySignalProtocolStore(sigIdentityKeyPair, sigRegistrationId);

  signal.ECKeyPair sigPreKeyPair = signal.Curve.generateKeyPair();
  signal.ECKeyPair sigSignedPreKeyPair = signal.Curve.generateKeyPair();

  Uint8List sigSignedPreKeySignature = signal.Curve.calculateSignature(
    sigSessionStore.getIdentityKeyPair().getPrivateKey(),
    sigSignedPreKeyPair.publicKey.serialize(),
  );

  String sigSignedPreKeySignatureStr =
      String.fromCharCodes(sigSignedPreKeySignature);

  String sigPublicKey =
      String.fromCharCodes(sigPreKeyPair.publicKey.serialize());

  String sigPrivateKey =
      String.fromCharCodes(sigPreKeyPair.privateKey.serialize());

  String sigSignedPublicKey =
      String.fromCharCodes(sigSignedPreKeyPair.publicKey.serialize());

  String sigSignedPrivateKey =
      String.fromCharCodes(sigSignedPreKeyPair.privateKey.serialize());

  String sigIdentityPublicKey = String.fromCharCodes(
      sigSessionStore.getIdentityKeyPair().getPublicKey().serialize());

  String sigIdentityPrivateKey = String.fromCharCodes(
      sigSessionStore.getIdentityKeyPair().getPrivateKey().serialize());

  return ClientKeys(
    publicKey: null,
    privateKey: null,
    sigRegistrationId: sigRegistrationId.toString(),
    sigPublicKey: encode(sigPublicKey),
    sigPrivateKey: encode(sigPrivateKey),
    sigSignedPublicKey: encode(sigSignedPublicKey),
    sigSignedPrivateKey: encode(sigSignedPrivateKey),
    sigSignedPreKeySignature: encode(sigSignedPreKeySignatureStr),
    sigIdentityPublicKey: encode(sigIdentityPublicKey),
    sigIdentityPrivateKey: encode(sigIdentityPrivateKey),
    sigPreKeys: sigPreKeysList,
  );
}
*/

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
