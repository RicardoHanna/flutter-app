// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemsbatches_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemsBatchesAdapter extends TypeAdapter<ItemsBatches> {
  @override
  final int typeId = 64;

  @override
  ItemsBatches read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemsBatches(
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
  void write(BinaryWriter writer, ItemsBatches obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.itemCode)
      ..writeByte(2)
      ..write(obj.batchID)
      ..writeByte(3)
      ..write(obj.sysNumber)
      ..writeByte(4)
      ..write(obj.batchNumber)
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
      other is ItemsBatchesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
