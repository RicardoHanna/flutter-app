// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itembrand_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemBrandAdapter extends TypeAdapter<ItemBrand> {
  @override
  final int typeId = 6;

  @override
  ItemBrand read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemBrand(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemBrand obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.brandCode)
      ..writeByte(1)
      ..write(obj.brandName)
      ..writeByte(2)
      ..write(obj.brandFName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemBrandAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
