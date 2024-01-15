// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemgroup_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemGroupAdapter extends TypeAdapter<ItemGroup> {
  @override
  final int typeId = 4;

  @override
  ItemGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemGroup(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemGroup obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.groupCode)
      ..writeByte(1)
      ..write(obj.groupName)
      ..writeByte(2)
      ..write(obj.groupFName)
      ..writeByte(3)
      ..write(obj.cmpCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
