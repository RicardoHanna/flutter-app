// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemswhses_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemsWhsesAdapter extends TypeAdapter<ItemsWhses> {
  @override
  final int typeId = 60;

  @override
  ItemsWhses read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemsWhses(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, ItemsWhses obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.itemCode)
      ..writeByte(2)
      ..write(obj.whsCode)
      ..writeByte(3)
      ..write(obj.qty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsWhsesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
