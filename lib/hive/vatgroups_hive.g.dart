// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vatgroups_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VATGroupsAdapter extends TypeAdapter<VATGroups> {
  @override
  final int typeId = 21;

  @override
  VATGroups read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VATGroups(
      cmpCode: fields[0] as String,
      vatCode: fields[1] as String,
      vatName: fields[2] as String,
      vatRate: fields[3] as int,
      baseCurCode: fields[4] as String,
      notes: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VATGroups obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.vatCode)
      ..writeByte(2)
      ..write(obj.vatName)
      ..writeByte(3)
      ..write(obj.vatRate)
      ..writeByte(4)
      ..write(obj.baseCurCode)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VATGroupsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
