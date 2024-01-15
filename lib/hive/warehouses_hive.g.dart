// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouses_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WarehousesAdapter extends TypeAdapter<Warehouses> {
  @override
  final int typeId = 25;

  @override
  Warehouses read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Warehouses(
      cmpCode: fields[0] as String,
      whsCode: fields[1] as String,
      whsName: fields[2] as String,
      whsFName: fields[3] as String,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Warehouses obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.whsCode)
      ..writeByte(2)
      ..write(obj.whsName)
      ..writeByte(3)
      ..write(obj.whsFName)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WarehousesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
