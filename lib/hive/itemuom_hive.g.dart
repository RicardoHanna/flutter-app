// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemuom_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemUOMAdapter extends TypeAdapter<ItemUOM> {
  @override
  final int typeId = 8;

  @override
  ItemUOM read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemUOM(
      fields[0] as String,
      fields[1] as String,
      fields[2] as double,
      fields[3] as String,
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemUOM obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.itemCode)
      ..writeByte(1)
      ..write(obj.uom)
      ..writeByte(2)
      ..write(obj.qtyperUOM)
      ..writeByte(3)
      ..write(obj.barCode)
      ..writeByte(4)
      ..write(obj.cmpCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemUOMAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
