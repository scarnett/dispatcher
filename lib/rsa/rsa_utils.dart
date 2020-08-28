import 'dart:math';
import 'dart:typed_data';
import 'package:dispatcher/rsa/rsa_key_helper.dart';
import 'package:pointycastle/export.dart';

/*
 * Example:
 * 
 * AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = getKeyPair();
 */
AsymmetricKeyPair<PublicKey, PrivateKey> getKeyPair() {
  RSAKeyGeneratorParameters keyParams = RSAKeyGeneratorParameters(
    BigInt.from(65537),
    2048,
    5,
  );

  FortunaRandom secureRandom = FortunaRandom();
  Random random = Random.secure();

  List<int> seeds = [];
  for (int i = 0; i < 32; i++) {
    seeds.add(random.nextInt(255));
  }

  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  ParametersWithRandom rngParams =
      ParametersWithRandom(keyParams, secureRandom);

  RSAKeyGenerator key = RSAKeyGenerator();
  key.init(rngParams);

  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = key.generateKeyPair();
  return keyPair;
}

/*
 * Example:
 * 
 * AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = getKeyPair();
 * print(encodePublicPem(keyPair.publicKey));
 */
String encodePublicPem(
  PublicKey publicKey,
) {
  return RsaKeyHelper().encodePublicKeyToPem(publicKey);
}

/*
 * Example:
 * 
 * AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = getKeyPair();
 * print(encodePrivatePem(keyPair.privateKey));
 */
String encodePrivatePem(
  PrivateKey privateKey,
) =>
    RsaKeyHelper().encodePrivateKeyToPem(privateKey);

/*
 * Example:
 * 
 * AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = getKeyPair();
 * Uint8List cipherText = encryptString(keyPair.publicKey, 'Hello World');
 * print('Encrypted: ${String.fromCharCodes(cipherText)}');
 */
Uint8List encryptString(
  PublicKey publicKey,
  String text,
) {
  AsymmetricKeyParameter<RSAPublicKey> keyParametersPublic =
      PublicKeyParameter(publicKey);

  RSAEngine cipher = RSAEngine()..init(true, keyParametersPublic);
  Uint8List cipherText = cipher.process(Uint8List.fromList(text.codeUnits));
  return cipherText;
}

/*
 * Examples:
 * 
 * AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = getKeyPair();
 * Uint8List cipherText = encryptString(keyPair.publicKey, 'Hello World');
 * print('Decrypted: ${decryptString(keyPair.privateKey, cipherText)}');
 * 
 * ---
 * 
 * RSAPrivateKey privateKey = RsaKeyHelper()
 *   .parsePrivateKeyFromPem(prefs.getString(AppKeys.APP_RSA_KEY));
 * print('Decrypted: ${decryptString(privateKey,
 *   Uint8List.fromList(viewModel.device.user.pin.codeUnits))}');
 */
String decryptString(
  PrivateKey privateKey,
  Uint8List cipherText,
) {
  AsymmetricKeyParameter<RSAPrivateKey> keyParametersPrivate =
      PrivateKeyParameter(privateKey);

  RSAEngine cipher = RSAEngine()..init(false, keyParametersPrivate);
  Uint8List decrypted = cipher.process(cipherText);
  return String.fromCharCodes(decrypted);
}

/// Formats a key
String printablePem(
  String key,
) {
  String temp = '';

  for (int i = 0; i < key.length; i++) {
    if ((i != 0) && ((i % 64) == 0)) {
      temp += '\n';
    }

    temp += key[i];
  }

  return temp;
}
