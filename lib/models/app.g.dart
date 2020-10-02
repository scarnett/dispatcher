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
      privateKey: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Dispatcher obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.privateKey);
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
