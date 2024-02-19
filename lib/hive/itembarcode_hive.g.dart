// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itembarcode_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemBarcodeAdapter extends TypeAdapter<ItemBarcode> {
  @override
  final int typeId = 58;

  @override
  ItemBarcode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemBarcode(
      cmpCode: fields[0] as String,
      itemCode: fields[1] as String,
      uomCode: fields[2] as String,
      barcode: fields[3] as String,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemBarcode obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.itemCode)
      ..writeByte(2)
      ..write(obj.uomCode)
      ..writeByte(3)
      ..write(obj.barcode)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemBarcodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
