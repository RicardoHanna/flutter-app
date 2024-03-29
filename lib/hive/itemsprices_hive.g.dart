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
      fields[3] as dynamic,
      fields[4] as String,
      fields[5] as bool,
      fields[6] as dynamic,
      fields[7] as dynamic,
      fields[8] as String,
      fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemsPrices obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.price)
      ..writeByte(8)
      ..write(obj.cmpCode)
      ..writeByte(9)
      ..write(obj.basePlCode);
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
