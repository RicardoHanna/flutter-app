// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salesemployeesitemsgroups_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesEmployeesItemsGroupsAdapter
    extends TypeAdapter<SalesEmployeesItemsGroups> {
  @override
  final int typeId = 32;

  @override
  SalesEmployeesItemsGroups read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesEmployeesItemsGroups(
      cmpCode: fields[0] as String,
      seCode: fields[1] as String,
      groupCode: fields[2] as String,
      reqFromWhsCode: fields[3] as dynamic,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SalesEmployeesItemsGroups obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cmpCode)
      ..writeByte(1)
      ..write(obj.seCode)
      ..writeByte(2)
      ..write(obj.groupCode)
      ..writeByte(3)
      ..write(obj.reqFromWhsCode)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesEmployeesItemsGroupsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
