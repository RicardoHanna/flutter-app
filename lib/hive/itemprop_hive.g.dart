// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemprop_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemPropAdapter extends TypeAdapter<ItemProp> {
  @override
  final int typeId = 59;

  @override
  ItemProp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemProp(
      cmpCode: fields[0] as String,
      itemCode: fields[1] as String,
      propCode: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemProp obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.itemCode)
      ..writeByte(2)
      ..write(obj.propCode)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemPropAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
