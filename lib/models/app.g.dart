// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DispatcherAdapter extends TypeAdapter<Dispatcher> {
  @override
  final int typeId = 0;

  @override
  Dispatcher read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dispatcher(
      identifier: fields[0] as String,
      clientKeys: fields[1] as ClientKeys,
    );
  }

  @override
  void write(BinaryWriter writer, Dispatcher obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.clientKeys);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClientKeysAdapter extends TypeAdapter<ClientKeys> {
  @override
  final int typeId = 1;

  @override
  ClientKeys read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClientKeys(
      publicKey: fields[0] as String,
      privateKey: fields[1] as String,
      sigRegistrationId: fields[2] as String,
      sigPublicKey: fields[3] as String,
      sigPrivateKey: fields[4] as String,
      sigSignedPublicKey: fields[5] as String,
      sigSignedPrivateKey: fields[6] as String,
      sigSignedPreKeySignature: fields[7] as String,
      sigIdentityPublicKey: fields[9] as String,
      sigIdentityPrivateKey: fields[10] as String,
      sigPreKeys: (fields[11] as List)?.cast<ClientPreKey>(),
    );
  }

  @override
  void write(BinaryWriter writer, ClientKeys obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.publicKey)
      ..writeByte(1)
      ..write(obj.privateKey)
      ..writeByte(2)
      ..write(obj.sigRegistrationId)
      ..writeByte(3)
      ..write(obj.sigPublicKey)
      ..writeByte(4)
      ..write(obj.sigPrivateKey)
      ..writeByte(5)
      ..write(obj.sigSignedPublicKey)
      ..writeByte(6)
      ..write(obj.sigSignedPrivateKey)
      ..writeByte(7)
      ..write(obj.sigSignedPreKeySignature)
      ..writeByte(9)
      ..write(obj.sigIdentityPublicKey)
      ..writeByte(10)
      ..write(obj.sigIdentityPrivateKey)
      ..writeByte(11)
      ..write(obj.sigPreKeys);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientKeysAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClientPreKeyAdapter extends TypeAdapter<ClientPreKey> {
  @override
  final int typeId = 2;

  @override
  ClientPreKey read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClientPreKey(
      keyId: fields[0] as int,
      publicKey: fields[1] as String,
      privateKey: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClientPreKey obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.keyId)
      ..writeByte(1)
      ..write(obj.publicKey)
      ..writeByte(2)
      ..write(obj.privateKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientPreKeyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
