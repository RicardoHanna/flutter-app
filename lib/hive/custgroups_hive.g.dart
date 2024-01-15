// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custgroups_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustGroupsAdapter extends TypeAdapter<CustGroups> {
  @override
  final int typeId = 22;

  @override
  CustGroups read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustGroups(
      cmpCode: fields[0] as String,
      grpCode: fields[1] as String,
      grpName: fields[2] as String,
      grpFName: fields[3] as String,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustGroups obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.grpCode)
      ..writeByte(2)
      ..write(obj.grpName)
      ..writeByte(3)
      ..write(obj.grpFName)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustGroupsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
