// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorization_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthorizationAdapter extends TypeAdapter<Authorization> {
  @override
  final int typeId = 13;

  @override
  Authorization read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Authorization(
      menucode: fields[0] as int,
      groupcode: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Authorization obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.menucode)
      ..writeByte(1)
      ..write(obj.groupcode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
