// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itemcateg_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemCategAdapter extends TypeAdapter<ItemCateg> {
  @override
  final int typeId = 5;

  @override
  ItemCateg read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemCateg(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemCateg obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.categCode)
      ..writeByte(1)
      ..write(obj.categName)
      ..writeByte(2)
      ..write(obj.categFName)
      ..writeByte(3)
      ..write(obj.cmpCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemCategAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
