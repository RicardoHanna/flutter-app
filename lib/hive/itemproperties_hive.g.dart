// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemproperties_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemPropertiesAdapter extends TypeAdapter<ItemProperties> {
  @override
  final int typeId = 58;

  @override
  ItemProperties read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemProperties(
      cmpCode: fields[0] as String,
      propCode: fields[1] as String,
      propName: fields[2] as String,
      propFName: fields[3] as String,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemProperties obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.propCode)
      ..writeByte(2)
      ..write(obj.propName)
      ..writeByte(3)
      ..write(obj.propFName)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemPropertiesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
