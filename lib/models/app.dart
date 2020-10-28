import 'package:hive/hive.dart';

part 'app.g.dart';

@HiveType(typeId: 0)
class Dispatcher extends HiveObject {
  @HiveField(0)
  String identifier;

  @HiveField(1)
  ClientKeys clientKeys;

  Dispatcher({
    this.identifier,
    this.clientKeys,
  });

  Dispatcher copyWith({
    String identifier,
    ClientKeys clientKeys,
  }) =>
      Dispatcher(
        identifier: identifier ?? this.identifier,
        clientKeys: clientKeys ?? this.clientKeys,
      );
}

@HiveType(typeId: 1)
class ClientKeys extends HiveObject {
  @HiveField(0)
  String publicKey;

  @HiveField(1)
  String privateKey;

  @HiveField(2)
  final String sigRegistrationId;

  @HiveField(3)
  final String sigPublicKey;

  @HiveField(4)
  final String sigPrivateKey;

  @HiveField(5)
  final String sigSignedPublicKey;

  @HiveField(6)
  final String sigSignedPrivateKey;

  @HiveField(7)
  final String sigSignedPreKeySignature;

  @HiveField(9)
  final String sigIdentityPublicKey;

  @HiveField(10)
  final String sigIdentityPrivateKey;

  @HiveField(11)
  final List<ClientPreKey> sigPreKeys;

  ClientKeys({
    this.publicKey,
    this.privateKey,
    this.sigRegistrationId,
    this.sigPublicKey,
    this.sigPrivateKey,
    this.sigSignedPublicKey,
    this.sigSignedPrivateKey,
    this.sigSignedPreKeySignature,
    this.sigIdentityPublicKey,
    this.sigIdentityPrivateKey,
    this.sigPreKeys,
  });

  ClientKeys copyWith({
    String publicKey,
    String privateKey,
    int sigRegistrationId,
    String sigPublicKey,
    String sigPrivateKey,
    String sigSignedPublicKey,
    String sigSignedPrivateKey,
    String sigSignedPrekeySignature,
    String sigIdentityPublicKey,
    String sigIdentityPrivateKey,
    List<ClientPreKey> sigPreKeys,
  }) =>
      ClientKeys(
        publicKey: publicKey ?? this.publicKey,
        privateKey: privateKey ?? this.privateKey,
        sigRegistrationId: sigRegistrationId ?? this.sigRegistrationId,
        sigPublicKey: sigPublicKey ?? this.sigPublicKey,
        sigPrivateKey: sigPrivateKey ?? this.sigPrivateKey,
        sigSignedPublicKey: sigSignedPublicKey ?? this.sigSignedPublicKey,
        sigSignedPrivateKey: sigSignedPrivateKey ?? this.sigSignedPrivateKey,
        sigSignedPreKeySignature:
            sigSignedPreKeySignature ?? this.sigSignedPreKeySignature,
        sigIdentityPublicKey: sigIdentityPublicKey ?? this.sigIdentityPublicKey,
        sigIdentityPrivateKey:
            sigIdentityPrivateKey ?? this.sigIdentityPrivateKey,
        sigPreKeys: sigPreKeys ?? this.sigPreKeys,
      );
}

@HiveType(typeId: 2)
class ClientPreKey extends HiveObject {
  @HiveField(0)
  final int keyId;

  @HiveField(1)
  final String publicKey;

  @HiveField(2)
  final String privateKey;

  ClientPreKey({
    this.keyId,
    this.publicKey,
    this.privateKey,
  });

  ClientPreKey copyWith({
    int keyId,
    String publicKey,
    String privateKey,
  }) =>
      ClientPreKey(
        keyId: keyId ?? this.keyId,
        publicKey: publicKey ?? this.publicKey,
        privateKey: privateKey ?? this.privateKey,
      );

  dynamic toJson() => {
        'key_id': keyId,
        'public_key': publicKey,
        // 'private_key': privateKey,
      };

  static List<dynamic> toJsonList(
    List<ClientPreKey> preKeys,
  ) =>
      (preKeys == null)
          ? []
          : preKeys.map((ClientPreKey preKey) => preKey.toJson()).toList();
}
