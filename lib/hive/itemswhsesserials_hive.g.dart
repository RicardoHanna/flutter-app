// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemswhsesserials_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemsWhsesSerialsAdapter extends TypeAdapter<ItemsWhsesSerials> {
  @override
  final int typeId = 61;

  @override
  ItemsWhsesSerials read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemsWhsesSerials(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as dynamic,
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemsWhsesSerials obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.itemCode)
      ..writeByte(2)
      ..write(obj.whsCode)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.serialID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsWhsesSerialsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
