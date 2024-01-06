// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adminsubmenu_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdminSubMenuAdapter extends TypeAdapter<AdminSubMenu> {
  @override
  final int typeId = 14;

  @override
  AdminSubMenu read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdminSubMenu(
      groupcode: fields[0] as int,
      groupname: fields[1] as String,
      grouparname: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AdminSubMenu obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.groupcode)
      ..writeByte(1)
      ..write(obj.groupname)
      ..writeByte(2)
      ..write(obj.grouparname);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminSubMenuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
