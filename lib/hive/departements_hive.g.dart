// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'departements_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DepartementsAdapter extends TypeAdapter<Departements> {
  @override
  final int typeId = 18;

  @override
  Departements read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Departements(
      cmpCode: fields[0] as String,
      depCode: fields[1] as String,
      depName: fields[2] as String,
      depFName: fields[3] as String,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Departements obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.depCode)
      ..writeByte(2)
      ..write(obj.depName)
      ..writeByte(3)
      ..write(obj.depFName)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartementsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
