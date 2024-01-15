// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'regions_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RegionsAdapter extends TypeAdapter<Regions> {
  @override
  final int typeId = 24;

  @override
  Regions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Regions(
      cmpCode: fields[0] as String,
      regCode: fields[1] as String,
      regName: fields[2] as String,
      regFName: fields[3] as String,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Regions obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.regCode)
      ..writeByte(2)
      ..write(obj.regName)
      ..writeByte(3)
      ..write(obj.regFName)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
