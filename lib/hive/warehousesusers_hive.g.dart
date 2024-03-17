// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehousesusers_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WarehousesUsersAdapter extends TypeAdapter<WarehousesUsers> {
  @override
  final int typeId = 65;

  @override
  WarehousesUsers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WarehousesUsers(
      userCode: fields[0] as String,
      whsCode: fields[1] as String,
      defaultwhsCode: fields[2] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, WarehousesUsers obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userCode)
      ..writeByte(1)
      ..write(obj.whsCode)
      ..writeByte(2)
      ..write(obj.defaultwhsCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WarehousesUsersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
