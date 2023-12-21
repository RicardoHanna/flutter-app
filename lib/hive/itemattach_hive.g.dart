// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemattach_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAttachAdapter extends TypeAdapter<ItemAttach> {
  @override
  final int typeId = 7;

  @override
  ItemAttach read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemAttach(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemAttach obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.itemCode)
      ..writeByte(1)
      ..write(obj.attachmentType)
      ..writeByte(2)
      ..write(obj.attachmentPath)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAttachAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
