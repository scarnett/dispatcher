import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart';

List<int> decodePEM(
  String pem,
) {
  List<String> startsWith = [
    '-----BEGIN PUBLIC KEY-----',
    '-----BEGIN PRIVATE KEY-----',
    '-----BEGIN PGP PUBLIC KEY BLOCK-----\r\nVersion: React-Native-OpenPGP.js 0.1\r\nComment: http://openpgpjs.org\r\n\r\n',
    '-----BEGIN PGP PRIVATE KEY BLOCK-----\r\nVersion: React-Native-OpenPGP.js 0.1\r\nComment: http://openpgpjs.org\r\n\r\n',
  ];

  List<String> endsWith = [
    '-----END PUBLIC KEY-----',
    '-----END PRIVATE KEY-----',
    '-----END PGP PUBLIC KEY BLOCK-----',
    '-----END PGP PRIVATE KEY BLOCK-----',
  ];

  bool isOpenPgp = (pem.indexOf('BEGIN PGP') != -1);

  for (String s in startsWith) {
    if (pem.startsWith(s)) {
      pem = pem.substring(s.length);
    }
  }

  for (String s in endsWith) {
    if (pem.endsWith(s)) {
      pem = pem.substring(0, (pem.length - s.length));
    }
  }

  if (isOpenPgp) {
    int index = pem.indexOf('\r\n');
    pem = pem.substring(0, index);
  }

  pem = pem.replaceAll('\n', '');
  pem = pem.replaceAll('\r', '');
  return base64.decode(pem);
}

class RsaKeyHelper {
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateKeyPair() {
    RSAKeyGeneratorParameters keyParams =
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 12);

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
    return key.generateKeyPair();
  }

  String encrypt(
    String plainText,
    RSAPublicKey publicKey,
  ) {
    RSAEngine cipher = RSAEngine()
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    Uint8List cipherText =
        cipher.process(Uint8List.fromList(plainText.codeUnits));
    return String.fromCharCodes(cipherText);
  }

  String decrypt(
    String ciphertext,
    RSAPrivateKey privateKey,
  ) {
    RSAEngine cipher = RSAEngine()
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    Uint8List decrypted =
        cipher.process(Uint8List.fromList(ciphertext.codeUnits));
    return String.fromCharCodes(decrypted);
  }

  RSAPublicKey parsePublicKeyFromPem(
    String pemString,
  ) {
    List<int> publicKeyDER = decodePEM(pemString);
    ASN1Parser asn1Parser = ASN1Parser(publicKeyDER);
    ASN1Sequence topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    ASN1Object publicKeyBitString = topLevelSeq.elements[1];

    ASN1Parser publicKeyAsn = ASN1Parser(publicKeyBitString.contentBytes());
    ASN1Sequence publicKeySeq = publicKeyAsn.nextObject();
    ASN1Integer modulus = publicKeySeq.elements[0] as ASN1Integer;
    ASN1Integer exponent = publicKeySeq.elements[1] as ASN1Integer;

    RSAPublicKey rsaPublicKey =
        RSAPublicKey(modulus.valueAsBigInteger, exponent.valueAsBigInteger);

    return rsaPublicKey;
  }

  RSAPrivateKey parsePrivateKeyFromPem(
    String pemString,
  ) {
    List<int> privateKeyDER = decodePEM(pemString);
    ASN1Parser asn1Parser = ASN1Parser(privateKeyDER);
    ASN1Sequence topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    // ASN1Object version = topLevelSeq.elements[0];
    // ASN1Object algorithm = topLevelSeq.elements[1];
    ASN1Object privateKey = topLevelSeq.elements[2];

    asn1Parser = ASN1Parser(privateKey.contentBytes());
    ASN1Sequence pkSeq = asn1Parser.nextObject() as ASN1Sequence;

    // version = pkSeq.elements[0];
    ASN1Integer modulus = pkSeq.elements[1] as ASN1Integer;
    // ASN1Integer publicExponent = pkSeq.elements[2] as ASN1Integer;
    ASN1Integer privateExponent = pkSeq.elements[3] as ASN1Integer;
    ASN1Integer p = pkSeq.elements[4] as ASN1Integer;
    ASN1Integer q = pkSeq.elements[5] as ASN1Integer;
    // ASN1Integer exp1 = pkSeq.elements[6] as ASN1Integer;
    // ASN1Integer exp2 = pkSeq.elements[7] as ASN1Integer;
    // ASN1Integer co = pkSeq.elements[8] as ASN1Integer;

    RSAPrivateKey rsaPrivateKey = RSAPrivateKey(
      modulus.valueAsBigInteger,
      privateExponent.valueAsBigInteger,
      p.valueAsBigInteger,
      q.valueAsBigInteger,
    );

    return rsaPrivateKey;
  }

  String encodePublicKeyToPem(
    RSAPublicKey publicKey,
  ) {
    ASN1Sequence algorithmSeq = ASN1Sequence();
    ASN1Object algorithmAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList(
      [0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1],
    ));

    ASN1Object paramsAsn1Obj =
        ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithmSeq.add(algorithmAsn1Obj);
    algorithmSeq.add(paramsAsn1Obj);

    ASN1Sequence publicKeySeq = ASN1Sequence();
    publicKeySeq.add(ASN1Integer(publicKey.modulus));
    publicKeySeq.add(ASN1Integer(publicKey.exponent));

    ASN1BitString publicKeySeqBitString =
        ASN1BitString(Uint8List.fromList(publicKeySeq.encodedBytes));

    ASN1Sequence topLevelSeq = ASN1Sequence();
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeySeqBitString);

    String dataBase64 = base64.encode(topLevelSeq.encodedBytes);
    return '''-----BEGIN PUBLIC KEY-----\r\n$dataBase64\r\n-----END PUBLIC KEY-----''';
  }

  String encodePrivateKeyToPem(
    RSAPrivateKey privateKey,
  ) {
    ASN1Integer version = ASN1Integer(BigInt.from(0));
    ASN1Sequence algorithmSeq = ASN1Sequence();
    ASN1Object algorithmAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList(
      [0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1],
    ));

    ASN1Object paramsAsn1Obj =
        ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithmSeq.add(algorithmAsn1Obj);
    algorithmSeq.add(paramsAsn1Obj);

    ASN1Sequence privateKeySeq = ASN1Sequence();
    ASN1Integer modulus = ASN1Integer(privateKey.n);
    ASN1Integer publicExponent = ASN1Integer(BigInt.parse('65537'));
    ASN1Integer privateExponent = ASN1Integer(privateKey.d);
    ASN1Integer p = ASN1Integer(privateKey.p);
    ASN1Integer q = ASN1Integer(privateKey.q);
    BigInt dP = privateKey.d % (privateKey.p - BigInt.from(1));
    ASN1Integer exp1 = ASN1Integer(dP);
    BigInt dQ = privateKey.d % (privateKey.q - BigInt.from(1));
    ASN1Integer exp2 = ASN1Integer(dQ);
    BigInt iQ = privateKey.q.modInverse(privateKey.p);
    ASN1Integer co = ASN1Integer(iQ);

    privateKeySeq.add(version);
    privateKeySeq.add(modulus);
    privateKeySeq.add(publicExponent);
    privateKeySeq.add(privateExponent);
    privateKeySeq.add(p);
    privateKeySeq.add(q);
    privateKeySeq.add(exp1);
    privateKeySeq.add(exp2);
    privateKeySeq.add(co);

    ASN1OctetString publicKeySeqOctetString =
        ASN1OctetString(Uint8List.fromList(privateKeySeq.encodedBytes));

    ASN1Sequence topLevelSeq = ASN1Sequence();
    topLevelSeq.add(version);
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeySeqOctetString);

    String dataBase64 = base64.encode(topLevelSeq.encodedBytes);
    return '-----BEGIN PRIVATE KEY-----\r\n$dataBase64\r\n-----END PRIVATE KEY-----';
  }
}
