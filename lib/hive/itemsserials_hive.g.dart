// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemsserials_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemsSerialsAdapter extends TypeAdapter<ItemsSerials> {
  @override
  final int typeId = 62;

  @override
  ItemsSerials read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemsSerials(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as int,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as DateTime,
      fields[8] as DateTime,
      fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemsSerials obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.itemCode)
      ..writeByte(2)
      ..write(obj.serialID)
      ..writeByte(3)
      ..write(obj.sysNumber)
      ..writeByte(4)
      ..write(obj.serialNumber)
      ..writeByte(5)
      ..write(obj.mnfSerial)
      ..writeByte(6)
      ..write(obj.lotNumber)
      ..writeByte(7)
      ..write(obj.mnfDate)
      ..writeByte(8)
      ..write(obj.expDate)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsSerialsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
