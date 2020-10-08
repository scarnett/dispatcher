import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:openpgp/key_options.dart';
import 'package:openpgp/key_pair.dart';
import 'package:openpgp/openpgp.dart';
import 'package:openpgp/options.dart';

/// Generate the keys
Future<KeyPair> generateKeyPair(
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
) =>
    base64.encode(utf8.encode(text));

/// Decodes some text
String decode(
  String str,
) =>
    String.fromCharCodes(base64.decode(str));
