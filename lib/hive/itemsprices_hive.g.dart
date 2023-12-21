// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemsprices_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemsPricesAdapter extends TypeAdapter<ItemsPrices> {
  @override
  final int typeId = 10;

  @override
  ItemsPrices read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemsPrices(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as double,
      fields[4] as String,
      fields[5] as bool,
      fields[6] as double,
      fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ItemsPrices obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.plCode)
      ..writeByte(1)
      ..write(obj.itemCode)
      ..writeByte(2)
      ..write(obj.uom)
      ..writeByte(3)
      ..write(obj.basePrice)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.auto)
      ..writeByte(6)
      ..write(obj.disc)
      ..writeByte(7)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsPricesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
