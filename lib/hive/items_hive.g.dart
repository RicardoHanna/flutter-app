// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemsAdapter extends TypeAdapter<Items> {
  @override
  final int typeId = 3;

  @override
  Items read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Items(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as String,
      fields[8] as String,
      fields[9] as String,
      fields[10] as String,
      fields[11] as String,
      fields[12] as String,
      fields[13] as String,
      fields[14] as String,
      fields[15] as double,
      fields[16] as bool,
      fields[17] as double,
      fields[18] as String,
      fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Items obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.itemCode)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.itemPrName)
      ..writeByte(3)
      ..write(obj.itemFName)
      ..writeByte(4)
      ..write(obj.itemPrFName)
      ..writeByte(5)
      ..write(obj.groupCode)
      ..writeByte(6)
      ..write(obj.categCode)
      ..writeByte(7)
      ..write(obj.brandCode)
      ..writeByte(8)
      ..write(obj.itemType)
      ..writeByte(9)
      ..write(obj.barCode)
      ..writeByte(10)
      ..write(obj.uom)
      ..writeByte(11)
      ..write(obj.picture)
      ..writeByte(12)
      ..write(obj.remark)
      ..writeByte(13)
      ..write(obj.brand)
      ..writeByte(14)
      ..write(obj.manageBy)
      ..writeByte(15)
      ..write(obj.vatRate)
      ..writeByte(16)
      ..write(obj.active)
      ..writeByte(17)
      ..write(obj.weight)
      ..writeByte(18)
      ..write(obj.charect1)
      ..writeByte(19)
      ..write(obj.charact2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
